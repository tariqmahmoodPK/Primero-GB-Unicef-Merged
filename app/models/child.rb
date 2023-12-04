# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# The truth of it is, this is a long class.
# Just the same, it shouldn't exceed 300 lines (250 lines of active code).

# The central Primero model object that represents an individual's case.
# In spite of the name, this will represent adult cases as well.
class Child < ApplicationRecord
  RISK_LEVEL_HIGH = 'high'
  RISK_LEVEL_NONE = 'none'
  NAME_FIELDS     = %w[name name_nickname name_other].freeze

  self.table_name = 'cases'

  def self.parent_form
    'case'
  end

  # This module updates photo_keys with the before_save callback and needs to
  # run before the before_save callback in Historical to make the history
  include Record
  include Searchable
  include Historical
  include BIADerivedFields
  include CareArrangements
  include UNHCRMapping
  include Ownable
  include AutoPopulatable
  include Serviceable
  include Reopenable
  include Workflow
  include Flaggable
  include Transitionable
  include Approvable
  include Alertable
  include Attachable
  include Noteable
  include EagerLoadable
  include Webhookable
  include Kpi::GBVChild
  include DuplicateIdAlertable
  include FollowUpable
  include LocationCacheable
  # Helper Methods for the Graphs
  extend GraphHelpers
  # Methods to Calculate Stats for Graphs
  extend Graphs

  # Accessors
  store_accessor(
    :data,
    :case_id, :case_id_code, :case_id_display,
    :nickname, :name, :protection_concerns, :consent_for_tracing, :hidden_name,
    :name_first, :name_middle, :name_last, :name_nickname, :name_other,
    :registration_date, :age, :estimated, :date_of_birth, :sex, :address_last,
    :risk_level, :date_case_plan, :case_plan_due_date, :date_case_plan_initiated,
    :date_closure, :assessment_due_date, :assessment_requested_on,
    :followup_subform_section, :protection_concern_detail_subform_section,
    :disclosure_other_orgs,
    :ration_card_no, :icrc_ref_no, :unhcr_id_no, :unhcr_individual_no, :un_no, :other_agency_id,
    :survivor_code_no, :national_id_no, :other_id_no, :biometrics_id, :family_count_no, :dss_id, :camp_id, :cpims_id,
    :tent_number, :nfi_distribution_id,
    :nationality, :ethnicity, :religion, :language, :sub_ethnicity_1, :sub_ethnicity_2, :country_of_origin,
    :displacement_status, :marital_status, :disability_type, :incident_details,
    :location_current, :tracing_status, :name_caregiver,
    :registry_id_display, :registry_name, :registry_no, :registry_location_current,
    :urgent_protection_concern, :child_preferences_section, :family_details_section, :care_arrangements_section,
    :duplicate, :cp_case_plan_subform_case_plan_interventions, :has_case_plan
  )

  # Associations
  has_many   :incidents      ,                      foreign_key: :incident_case_id
  has_many   :matched_traces , class_name: 'Trace', foreign_key: 'matched_case_id'
  has_many   :duplicates     , class_name: 'Child', foreign_key: 'duplicate_case_id'
  belongs_to :duplicate_of   , class_name: 'Child', foreign_key: 'duplicate_case_id', optional: true
  belongs_to :registry_record,                      foreign_key: :registry_record_id, optional: true

  # Scopes
  scope :by_date_of_birth, -> { where.not('data @> ?', { date_of_birth: nil }.to_json) }
  # Search for records in KPK Province
  scope :attachment_with_specific_type, -> (document_type) { includes(:attachments).where(attachments: { type_of_document: document_type }) }
  scope :attachment_with_specific_type_and_user, -> (username, document_type) { includes(:attachments).where("data @> ?", { owned_by: username }.to_json).where(attachments: { type_of_document: document_type }) }

  scope :with_province, -> {
    where("location_current LIKE ?", "KPK%").where('risk_level = ?', 'high')
  }

  def self.sortable_text_fields
    %w[name case_id_display national_id_no registry_no]
  end

  def self.filterable_id_fields
    # The fields family_count_no and dss_id are hacked in only because of Bangladesh
    # The fields camp_id, tent_number and nfi_distribution_id are hacked in only because of Iraq
    %w[ unique_identifier short_id case_id_display case_id
        ration_card_no icrc_ref_no rc_id_no unhcr_id_no unhcr_individual_no un_no
        other_agency_id survivor_code_no national_id_no other_id_no biometrics_id
        family_count_no dss_id camp_id tent_number nfi_distribution_id oscar_number registry_no ]
  end

  def self.get_child_statuses(user)
    role_name = user.role.name
    return { permission: false } unless ['CPI In-charge', 'CPO', 'CP Manager', 'Referral'].include?(role_name)

    case role_name
    when "CPO"
      registered_cases = Child.get_registered_cases_with_user(user.user_name).total
      harm_cases = Child.get_significant_harm_cases_with_user(user.user_name).total
    when "CPI In-charge"
      registered_cases = get_registered_cases_with_user_group(user.user_groups.pluck(:unique_id)).total
      harm_cases = Child.get_significant_harm_cases_with_user_group(user.user_groups.pluck(:unique_id)).total
    else
      registered_cases = Child.get_registered_cases.total
      harm_cases = Child.get_significant_harm_cases.total
    end

    if role_name.in? ["CPI In-charge", "CPO"]
      resolved_cases = role_name.eql?("CPO") ? Child.get_resolved_cases_with_user(user.user_name).total : Child.get_resolved_cases_with_user(user.user_groups.first.users.pluck(:user_name)).total
      closed_cases = role_name.eql?("CPO") ? Child.get_closed_cases_with_user(user.user_name).total : Child.get_closed_cases_with_user(user.user_groups.first.users.pluck(:user_name)).total
    end
    statuses = { "stats" => {} }

    statuses["stats"]["Role"] = role_name
    statuses["stats"]["Number of Cases"] = Child.count
    statuses["stats"]["data"] = { "Registered (Open)": registered_cases, "Significant Harm": harm_cases }
    statuses["stats"]["data"].merge!("Pending Approval for Closure": Child.pending_cases_to_assigned(user.user_groups.first.users.pluck(:user_name)).size) if role_name.eql?("CPI In-charge")
    statuses["stats"]["data"].merge!("Closed": closed_cases) if role_name.in? ["CPI In-charge", "CPO"]
    statuses["stats"]["data"].merge!("Assigned to Me": Child.get_cases_assigned_to_specific_user(user).total) if role_name.eql?("CPO")

    statuses
  end

  def self.quicksearch_fields
    filterable_id_fields + NAME_FIELDS
  end

  def self.summary_field_names
    common_summary_fields + %w[
      case_id_display name survivor_code_no age sex registration_date
      hidden_name workflow case_status_reopened module_id registry_record_id
    ]
  end

  def self.alert_count_self(current_user)
    records_owned_by = open_enabled_records.owned_by(current_user.user_name).ids
    # TODO: Once relation between transition and record is fixee, use joins(:transitions)
    records_referred_users = open_enabled_records.joins(
      "INNER JOIN transitions ON transitions.record_type = 'Child' AND (transitions.record_id)::uuid = cases.id"
    ).where(transitions:
      {
        type: Referral.name,
        status: [Transition::STATUS_INPROGRESS, Transition::STATUS_ACCEPTED],
        transitioned_to: current_user.user_name
      }).ids
    (records_referred_users + records_owned_by).uniq.count
  end

  def self.child_matching_field_names
    MatchingConfiguration.matchable_fields('case', false).pluck(:name) | MatchingConfiguration::DEFAULT_CHILD_FIELDS
  end

  def self.family_matching_field_names
    MatchingConfiguration.matchable_fields('case', true).pluck(:name) | MatchingConfiguration::DEFAULT_INQUIRER_FIELDS
  end

  def self.api_path
    '/api/v2/cases'
  end

  searchable do
    filterable_id_fields.each { |f| string( "#{f}_filterable", as: "#{f}_filterable_sci") { data[f] } }
    sortable_text_fields.each { |f| string( "#{f}_sortable"  , as: "#{f}_sortable_sci"  ) { data[f] } }

    Child.child_matching_field_names.each { |f| text_index(f, suffix: 'matchable') }
    Child.family_matching_field_names.each do |f|
      text_index(f, suffix: 'matchable', subform_field_name: 'family_details_section')
    end

    quicksearch_fields.each { |f| text_index(f) }

    %w[registration_date date_case_plan_initiated assessment_requested_on date_closure].each { |f| date(f) }
    %w[estimated urgent_protection_concern consent_for_tracing has_case_plan].each do |f|
      boolean(f) { data[f] == true || data[f] == 'true' }
    end
    %w[day_of_birth age].each { |f| integer(f) }
    %w[id status sex current_care_arrangements_type].each { |f| string(f, as: "#{f}_sci") }

    string :risk_level, as: 'risk_level_sci' do
      risk_level.present? ? risk_level : RISK_LEVEL_NONE
    end
    string :protection_concerns, multiple: true

    date(:assessment_due_dates, multiple: true) { Tasks::AssessmentTask.from_case(self).map(&:due_date) }
    date(:case_plan_due_dates , multiple: true) { Tasks::CasePlanTask.from_case(self).map(&:due_date) }
    date(:followup_due_dates  , multiple: true) { Tasks::FollowUpTask.from_case(self).map(&:due_date) }

    boolean(:has_incidents) { incidents.size.positive? }

    # Define a 'text' field for Sunspot indexing.
    # This field extracts the value associated with the 'nationality_b80911e' key from the 'data' JSON object.
    text :nationality_b80911e do
      data["nationality_b80911e"]
    end

    text :beneficiary_of_social_protection_programs__b2367d9 do
      parent_guardian_data = data["parent_guardian_38aba74"]
      parent_guardian_data.present? ? parent_guardian_data.map { |item| item["beneficiary_of_social_protection_programs__b2367d9"] }[0] : nil
    end

    text :parent_guardian_b481d19 do
      parent_guardian_data = data["parent_guardian_38aba74"]
      parent_guardian_data.present? ? parent_guardian_data.map { |item| item["parent_guardian_b481d19"] }[0] : nil
    end

    text :status_d359d3a do
      parent_guardian_data = data["parent_guardian_38aba74"]
      parent_guardian_data.present? ? parent_guardian_data.map { |item| item["status_d359d3a"] }[0] : nil
    end
  end

  # Validations
  validate :validate_date_of_birth

  # Callbacks
  before_save   :sync_protection_concerns
  before_save   :auto_populate_name
  before_save   :stamp_registry_fields
  before_save   :calculate_has_case_plan
  before_create :hide_name
  # Allows to get the current_user object in model's lifecycle
  after_update   :get_current_user
  after_create   :get_current_user
  # Send a mail when Child record is created
  after_create  :send_case_registration_message
  # Method that send mails when specific 'conditions are met' / 'events are triggered'
  after_update  :send_case_event_emails
  after_save    :save_incidents

  class << self
    alias super_new_with_user new_with_user
    def new_with_user(user, data = {})
      new_case = super_new_with_user(user, data).tap do |local_case|
        local_case.registry_record_id ||= local_case.data.delete('registry_record_id')
      end
      new_case
    end
  end

  alias super_defaults defaults
  def defaults
    super_defaults
    self.registration_date ||= Date.today
    self.notes_section ||= []
  end

  def self.report_filters
    [
      { 'attribute' => 'status'      , 'value' => [STATUS_OPEN] },
      { 'attribute' => 'record_state', 'value' => ['true']      }
    ]
  end

  # TODO: does this need reporting location???
  # TODO: does this need the reporting_location_config field key
  # TODO: refactor with nested
  def self.minimum_reportable_fields
    {
      'boolean' => ['record_state'],
      'string' => %w[
        status sex risk_level owned_by_agency_id owned_by workflow workflow_status risk_level consent_reporting
      ],
      'multistring' => %w[associated_user_names associated_user_agencies owned_by_groups],
      'date' => ['registration_date'],
      'integer' => ['age'],
      'location' => %w[owned_by_location location_current]
    }
  end

  def self.nested_reportable_types
    [ReportableProtectionConcern, ReportableService, ReportableFollowUp]
  end

  def validate_date_of_birth
    return unless date_of_birth.present? && (!date_of_birth.is_a?(Date) || date_of_birth.year > Date.today.year)

    errors.add(:date_of_birth, I18n.t('errors.models.child.date_of_birth'))
  end

  alias super_update_properties update_properties
  def update_properties(user, data)
    build_or_update_incidents(user, (data.delete('incident_details') || []))
    self.registry_record_id = data.delete('registry_record_id') if data.key?('registry_record_id')
    self.mark_for_reopen = @incidents_to_save.present?
    super_update_properties(user, data)
  end

  def build_or_update_incidents(user, incidents_data)
    return unless incidents_data

    @incidents_to_save = incidents_data.map do |incident_data|
      incident = Incident.find_by(id: incident_data['unique_id'])
      incident ||= IncidentCreationService.incident_from_case(self, incident_data, module_id, user)
      unless incident.new_record?
        incident_data.delete('unique_id')
        incident.data = RecordMergeDataHashService.merge_data(incident.data, incident_data) unless incident.new_record?
      end
      incident.has_changes_to_save? ? incident : nil
    end.compact
  end

  # Sending a Notification on Case Record Being Created
  # Assuming, New Case Record Creation in done through Helpline Only
  def send_case_registration_message
    registered_case = self

    # TODO Verify this is the right way to get the CPO
    # Getting CPO of the Case
    cpo_user = User.joins(:role).where(role: { unique_id: "role-cp-administrator" }).find_by(location: registered_case.data["owned_by_location"])

    CaseLifecycleEventsNotificationMailer.send_case_registered_cpo_notification(registered_case, cpo_user).deliver_later

    # Send Whatsapp Notification
    if cpo_user&.phone
      message_params = {
        case: registered_case,
        cpo_user: cpo_user,
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_registered_cpo_notification.text.erb"
      service = ContentGeneratorService.new
      message_content = service.generate_message_content(file_path, message_params)

      twilio_service = TwilioWhatsappService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  def send_case_event_emails
    # Define a configuration hash mapping condition keys to mailer methods
    event_config = {
      'declaration_by_case_worker_9ccdf48'                   => :send_case_registration_completed_notification,
      'i_declare_that_to_the_best_of_my_knowledge_the_above_stated_facts_are_true_404f861' => :send_case_registration_verified_notification,
      'declaration_by_case_worker_9ac8a1d'                   => :send_initial_assessment_completed_notification        ,
      'verification_of_initial_assessment_560f3ed'           => :send_initial_assessment_verified_notification         ,
      'declaration_from_case_worker_5bb55e3'                 => :send_comprehensive_assessment_completed_notification  ,
      'verification_of_comprehensive_assessment_3201713'     => :send_comprehensive_assessment_verified_notification   ,
      'declaration_from_case_worker_ec811f6'                 => :send_case_plan_completed_notification                 ,
      'verification_of_case_plan_e2b7c06'                    => :send_case_plan_verified_notification                  ,
      'declaration_by_case_worker_f2bdb12'                   => :send_alternative_care_placement_completed_notification,
      'verification_by_the_child_protection_officer_67b3fbb' => :send_alternative_care_placement_verified_notification ,
      'follow_up_information_and_findings_fc87338'           => :send_monitoring_and_follow_up_subform_completed_notification,
      'verification_of_follow_up_findings_53492a4'           => :send_monitoring_and_follow_up_subform_verified_notification,
      'declaration_by_case_worker_6f6c306'                   => :send_case_transfer_completes_notification,
      'verification_by_child_protection_officer_21e7bd8'     => :send_case_transfer_verified_notification,
      'approval_for_case_transfer_3a58692'                   => :send_case_transfer_approved_notification,
    }

    updated_record = self

    data_before_update = previous_changes["data"][0]
    data_after_update = updated_record['data']

    event_config.each do |event_key, mailer_method|
      declaration_value = nil

      case event_key
      when "follow_up_information_and_findings_fc87338"
        if data_before_update.key?(event_key) && data_after_update.key?(event_key)
          original_data = data_before_update[event_key][0]["date_of_follow_up_fb341ff"]
          new_data = data_after_update[event_key][0]["date_of_follow_up_fb341ff"]

          if new_data.present? && original_data != new_data
            declaration_value = true
          end
        elsif data_after_update.key?(event_key) && data_after_update[event_key][0].key?("date_of_follow_up_fb341ff")
          declaration_value = true
        end
      else
        if data_before_update.key?(event_key) && data_after_update.key?(event_key)
          original_data = data_before_update[event_key]
          new_data = data_after_update[event_key]

          declaration_value = new_data if original_data != new_data
        elsif data_after_update.key?(event_key)
          declaration_value = data_after_update[event_key]
        end
      end

      if declaration_value
        if mailer_method && CaseLifecycleEventsNotificationMailer.respond_to?(mailer_method)
          CaseLifecycleEventsNotificationMailer.send(mailer_method, updated_record, @current_user, declaration_value).deliver_now
        else
          # Handle the case where the mailer method is not found
          raise "Unknown mailer method for event: #{event_key}"
        end

        twilio_service = TwilioWhatsappService.new
        to_phone_number = nil
        message_body = nil

        # Send Whatsapp Notification
        case mailer_method.to_s
        when "send_case_registration_completed_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if cpo_user&.phone
            message_params = {
              case: updated_record,
              user: user,
              user_name: user_name,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_registration_completed_notification.text.erb"
            service = ContentGeneratorService.new
            message_content = service.generate_message_content(file_path, message_params)

            to_phone_number = cpo_user.phone
            message_body = message_content
          end
        when "send_case_registration_verified_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_registration_verified_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        when "send_initial_assessment_completed_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if cpo_user&.phone
            message_params = {
              case: updated_record,
              user: user,
              user_name: user_name,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_initial_assessment_completed_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = cpo_user.phone
            message_body = message_content
          end
        when "send_initial_assessment_verified_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_initial_assessment_verified_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        when "send_comprehensive_assessment_completed_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if cpo_user&.phone
            message_params = {
              case: updated_record,
              user: user,
              user_name: user_name,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_comprehensive_assessment_completed_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = cpo_user.phone
            message_body = message_content
          end
        when "send_comprehensive_assessment_verified_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_comprehensive_assessment_verified_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        when "send_case_plan_completed_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if cpo_user&.phone
            message_params = {
              case: updated_record,
              user: user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_plan_completed_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = cpo_user.phone
            message_body = message_content
          end
        when "send_case_plan_verified_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_plan_verified_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        when "send_alternative_care_placement_completed_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if cpo_user&.phone
            message_params = {
              case: updated_record,
              user: user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_alternative_care_placement_completed_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = cpo_user.phone
            message_body = message_content
          end
        when "send_alternative_care_placement_verified_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_alternative_care_placement_verified_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        when "send_monitoring_and_follow_up_subform_completed_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if cpo_user&.phone
            message_params = {
              case: updated_record,
              user: user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_monitoring_and_follow_up_subform_completed_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = cpo_user.phone
            message_body = message_content
          end
        when "send_monitoring_and_follow_up_subform_verified_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_monitoring_and_follow_up_subform_verified_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        when "send_case_transfer_completes_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if cpo_user&.phone
            message_params = {
              case: updated_record,
              user: user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_transfer_completes_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = cpo_user.phone
            message_body = message_content
          end
        when "send_case_transfer_verified_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_transfer_verified_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        when "send_case_transfer_approved_notification"
          # SCW/Psy
          user_name = updated_record.data['owned_by']
          scw_psy_user = User.find_by(user_name: user_name)

          cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: scw_psy_user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

          cpo_user = cpo_users[0]

          # Send Whatsapp Notification
          if scw_psy_user&.phone
            message_params = {
              case: updated_record,
              user: cpo_user,
            }.with_indifferent_access

            file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_transfer_approved_notification.text.erb"
            message_content = ContentGeneratorService.new.generate_message_content(file_path, message_params)

            to_phone_number = scw_psy_user.phone
            message_body = message_content
          end
        else
        end

        twilio_service.send_whatsapp_message(to_phone_number, message_body)
      end
    end
  end

  def save_incidents
    return unless @incidents_to_save

    Incident.transaction do
      @incidents_to_save.each(&:save!)
    end
  end

  def to_s
    name.present? ? "#{name} (#{unique_identifier})" : unique_identifier
  end

  def auto_populate_name
    # This 2 step process is necessary because you don't want to overwrite self.name if auto_populate is off
    a_name = auto_populate('name')
    self.name = a_name if a_name.present?
  end

  def hide_name
    self.hidden_name = true if module_id == PrimeroModule::GBV
  end

  def set_instance_id
    system_settings = SystemSettings.current
    self.case_id ||= unique_identifier
    self.case_id_code ||= auto_populate('case_id_code', system_settings)
    self.case_id_display ||= create_case_id_display(system_settings)
  end

  def create_case_id_code(system_settings)
    separator = system_settings&.case_code_separator.present? ? system_settings.case_code_separator : ''
    id_code_parts = []
    if system_settings.present? && system_settings.case_code_format.present?
      system_settings.case_code_format.each { |cf| id_code_parts << PropertyEvaluator.evaluate(self, cf) }
    end
    id_code_parts.reject(&:blank?).join(separator)
  end

  def create_case_id_display(system_settings)
    [case_id_code, short_id].compact.join(auto_populate_separator('case_id_code', system_settings))
  end

  def display_id
    case_id_display
  end

  def day_of_birth
    return nil unless date_of_birth.is_a? Date

    AgeService.day_of_year(date_of_birth)
  end

  def calculate_has_case_plan
    interventions = cp_case_plan_subform_case_plan_interventions || []
    self.has_case_plan = interventions.any? do |intervention|
      intervention['intervention_service_to_be_provided'].present? || intervention['intervention_service_goal'].present?
    end

    has_case_plan
  end

  def sync_protection_concerns
    protection_concerns = self.protection_concerns || []
    from_subforms = protection_concern_detail_subform_section&.map { |pc| pc['protection_concern_type'] }&.compact || []
    self.protection_concerns = (protection_concerns + from_subforms).uniq
  end

  def stamp_registry_fields
    return unless changes_to_save.key?('registry_record_id')

    self.registry_id_display = registry_record&.registry_id_display
    self.registry_name = registry_record&.name
    self.registry_no = registry_record&.registry_no
    self.registry_location_current = registry_record&.location_current
  end

  def match_criteria
    match_criteria = data.slice(*Child.child_matching_field_names).compact
    match_criteria = match_criteria.merge(
      Child.family_matching_field_names.map do |field_name|
        [field_name, values_from_subform('family_details_section', field_name)]
      end.to_h
    )
    match_criteria = match_criteria.transform_values { |v| v.is_a?(Array) ? v.join(' ') : v }
    match_criteria.select { |_, v| v.present? }
  end

  def matches_to
    Trace
  end

  def associations_as_data(current_user = nil)
    return @associations_as_data if @associations_as_data

    incident_details = RecordScopeService.scope_with_user(incidents, current_user).map do |incident|
      incident.data&.reject { |_, v| RecordMergeDataHashService.array_of_hashes?(v) }
    end.compact || []
    @associations_as_data = { 'incident_details' => incident_details }
  end

  def associations_as_data_keys
    %w[incident_details]
  end

  # Save the Current User in an Instance variable for use in the Model
  def set_current_user(current_user)
    @current_user = current_user
  end

  private

  # Access the @current_user set in the set_current_user method
  def get_current_user
    user = @current_user
  end
end

# rubocop:enable Metrics/ClassLength
