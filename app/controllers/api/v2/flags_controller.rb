# frozen_string_literal: true

# Endpoint for managing flags for a record
class Api::V2::FlagsController < Api::V2::RecordResourceController
  before_action { authorize! :flag, model_class }
  after_action :send_email_for_flag, only: [:create]

  def create
    authorize! :flag_record, @record
    @flag = @record.add_flag(params['data']['message'], params['data']['date'], current_user.user_name)
    updates_for_record(@record)
    render :create, status: status
  end

  def update
    authorize! :flag_record, @record
    @flag = @record.remove_flag(params['id'], current_user.user_name, params['data']['unflag_message'])
    updates_for_record(@record)
  end

  def create_bulk
    authorize_all!(:flag, @records)
    model_class.batch_flag(@records, params['data']['message'], params['data']['date'].to_date, current_user.user_name)
  end

  def create_action_message
    'flag'
  end

  def update_action_message
    'unflag'
  end

  def create_bulk_record_resource
    'bulk_flag'
  end

  def status
    params[:data][:id].present? ? 204 : 200
  end

  private

  def send_email_for_flag
    cpo_user = User.joins(:role).where(role: { unique_id: "role-cp-administrator" }).find_by(location: @record.data["owned_by_location"])

    CaseLifecycleEventsNotificationMailer.send_case_flags_notification(@record, cpo_user).deliver_later

    # Send Whatsapp Notification
    if cpo_user&.phone
      message_params = {
        case: @record,
        cpo_user: cpo_user,
        workflow_stage: @record.data["workflow"]
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_flags_notification.text.erb"
      message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

      twilio_service = TwilioWhatsappService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end
end
