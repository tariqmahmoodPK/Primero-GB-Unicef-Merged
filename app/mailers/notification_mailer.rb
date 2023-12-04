# frozen_string_literal: true

# Sends email notifications for Approval requests and responses,
# Transition notification, and Transfer Requests.
# TODO: Break up into separate mailers.
class NotificationMailer < ApplicationMailer
  helper :application

  # 10-a
  # Case Closure Request | Mail to CPO/Mangers
  def manager_approval_request(record_id, approval_type, manager_user_name)
    @manager = User.find_by(user_name: manager_user_name) || (return log_not_found('Manager user', manager_user_name))
    @child = Child.find_by(id: record_id) || (return log_not_found('Case', record_id))
    @user = @child.owner || (return log_not_found('User', @child.owned_by))
    @approval_type = Lookup.display_value('lookup-approval-type', approval_type)
    @locale_email = @manager.locale || I18n.locale
    @role_name = @manager.role.name

    @email_content_html_yml_key = 'email_notification.approval_request_html'
    @email_content_text_yml_key = 'email_notification.approval_request'

    if assert_notifications_enabled(@manager)
      mail(to: @manager.email, subject: t('email_notification.approval_request_subject', id: @child.short_id, locale: @locale_email))
    end

    # Send Whatsapp Notifications
    if @manager.present? && @manager&.phone
      twilio_service = TwilioWhatsappService.new

      message_params = {
        case: @transition&.record,
        cpo_user: manager,
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_closure_request_notification.text.erb"
      message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

      to_phone_number = manager.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  # 10-b | # 10-c
  # Case Closure Request | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def manager_approval_response(record_id, approved, approval_type, manager_user_name)
    @child = Child.find_by(id: record_id) || (return log_not_found('Case', record_id))
    @owner = @child.owner || (return log_not_found('User', @child.owned_by))

    load_manager_approval_request(approved, approval_type, manager_user_name)

    #cpo
    user = @manager.user_name
    #scw/psy
    send_to_user_email = @owner.email
    send_to_user_name = @owner.user_name

    if approved == true
      @email_content_html_yml_key = 'email_notification.approval_response_approved_html'
      @email_content_text_yml_key = 'email_notification.approval_response_approved'
    elsif approved == false
      @email_content_html_yml_key = 'email_notification.approval_response_not_approved_html'
      @email_content_text_yml_key = 'email_notification.approval_response_not_approved'
    else
      @email_content_html_yml_key = 'email_notification.approval_response_html'
      @email_content_text_yml_key = 'email_notification.approval_response'
    end

    if assert_notifications_enabled(@owner)
      mail(to: @owner.email, subject: t('email_notification.approval_response_subject', id: @child.short_id, locale: @locale_email))
    end

    # Send Whatsapp Notifications
    if @owner.present? && @owner&.phone
      twilio_service = TwilioWhatsappService.new
      to_phone_number = nil
      message_body = nil

      case approved
      when true
        message_params = {
          case: @child,
          user_name: @manager.user_name
        }.with_indifferent_access

        file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_closure_approved_notification.text.erb"
        message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

        to_phone_number = cpo_user.phone
        message_body = message_content
      when false
        message_params = {
          case: @child,
          cpo_user:  @manager.user_name
        }.with_indifferent_access

        file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_closure_not_approved_notification.text.erb"
        message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

        to_phone_number = cpo_user.phone
        message_body = message_content
      end

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  # 1-b | 1-b ii| 1-a ii |
  # Case Assigned to SCW/Psychologist
  # Case Transfered | Transfered to CPO | Transfered to SCW/Psychologist |
  # And other Notifications too
  def transition_notify(transition_id)
    load_transition_for_email(Transition, transition_id)
    return log_not_found('Transition', transition_id) unless @transition

    transitioned_by_user = User.find_by(user_name: @transition.transitioned_by)
    @location = transitioned_by_user.location
    @workflow_stage = @transition&.record.workflow

    send_to_user = @transition&.transitioned_to_user
    send_to_role_name = send_to_user.role.name

    if @transition.key == "transfer"
      if send_to_role_name == "Child Helpline Officer"
        @email_content_html_yml_key = "email_notification.#{@transition.key}_cpo_html"
        @email_content_text_yml_key = "email_notification.#{@transition.key}_cpo"
      elsif send_to_role_name == "Psychologist" || send_to_role_name == "Social Case Worker"
        @email_content_html_yml_key = "email_notification.#{@transition.key}_scw_psy_html"
        @email_content_text_yml_key = "email_notification.#{@transition.key}_scw_psy"
      else
        @email_content_html_yml_key = "email_notification.#{@transition.key}_html"
        @email_content_text_yml_key = "email_notification.#{@transition.key}"
      end
    end

    if assert_notifications_enabled(@transition&.transitioned_to_user)
      mail(to: @transition&.transitioned_to_user&.email, subject: transition_subject(@transition&.record))
    end

    cpo_user = User.joins(:role).where(role: { unique_id: "role-cp-administrator" }).find_by(user_name: @transition.transitioned_by)

    # Send Whatsapp Notifications
    if send_to_user.present? && send_to_user&.phone
      twilio_service = TwilioWhatsappService.new
      to_phone_number = nil
      message_body = nil

      case @transition.key
      when "assign"
        message_params = {
          case: @transition&.record,
          cpo_user: cpo_user,
        }.with_indifferent_access

        file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_registered_scw_psychologist_notification.text.erb"
        message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

        to_phone_number = cpo_user.phone
        message_body = message_content
      when "transfer"
        message_params = {
          case: @transition&.record,
          transfered_by_user: transitioned_by_user,
          location: @location,
          workflow_stage: @workflow_stage
        }.with_indifferent_access

        if send_to_role_name == "Child Helpline Officer"
          file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_transfered_cpo_notification.text.erb"
          message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

          to_phone_number = cpo_user.phone
          message_body = message_content
        elsif send_to_role_name == "Psychologist" || send_to_role_name == "Social Case Worker"
          file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_transfered_scw_psychologist_notification.text.erb"
          message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

          to_phone_number = send_to_user.phone
          message_body = message_content
        end
      end

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  def transfer_request(transfer_request_id)
    load_transition_for_email(TransferRequest, transfer_request_id)
    return log_not_found('Transfer Request Transition', transfer_request_id) unless @transition
    return unless assert_notifications_enabled(@transition&.transitioned_to_user)

    mail(
      to: @transition&.transitioned_to_user&.email,
      subject: t('email_notification.transfer_request_subject'),
      locale: @locale_email
    )
  end

  private

  def log_not_found(type, id)
    Rails.logger.error(
      "Mail not sent. #{type.capitalize} #{id} not found."
    )
  end

  def assert_notifications_enabled(user)
    return true if user&.emailable?

    Rails.logger.info("Mail not sent. Notifications disabled for #{user&.user_name || 'nil user'}")

    false

    true
  end

  def manager_approval_message
    t('approvals.status.approved', locale: @locale_email)
  end

  def manager_rejected_message
    t('approvals.status.rejected', locale: @locale_email)
  end

  def load_manager_approval_request(approved, approval_type, manager_user_name)
    @manager = User.find_by(user_name: manager_user_name)
    lookup_name = @manager.gbv? ? 'lookup-gbv-approval-types' : 'lookup-approval-type'
    @approval_type = Lookup.display_value(lookup_name, approval_type)
    @locale_email = @owner.locale || I18n.locale
    @approval = approved ? manager_approval_message : manager_rejected_message
  end

  def load_transition_for_email(class_transition, id)
    @transition = class_transition.find_by(id: id)
    @locale_email = @transition&.transitioned_to_user&.locale || I18n.locale
  end

  def transition_subject(record)
    t(
      "email_notification.#{@transition.key}_subject",
      record_type: t("forms.record_types.#{record.class.parent_form}", locale: @locale_email),
      id: record.short_id,
      locale: @locale_email
    )
  end
end
