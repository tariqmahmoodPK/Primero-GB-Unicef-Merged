class CaseLifecycleEventsNotificationMailer < ApplicationMailer
  # 1-a # Case Registered Through Helpline
  def send_case_registered_cpo_notification(child_record, cpo_user)
    @case_record = child_record
    @case_id = child_record.short_id
    cpo_user = cpo_user

    return unless assert_notifications_enabled(cpo_user)

    subject = "Case #{@case_id} Referred to you via Helpline"

    mail(to: cpo_user.email, subject: subject) do |format|
      format.html { render __method__.to_s }
      format.text { render __method__.to_s }
    end
  end

  # 2-a
  # Case Registration Completed | Mail to CPO
  # Case id | SCW/Psychologist | CPO User Email
  def send_case_registration_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #
    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(cpo_users[0])

    user_email = cpo_users[0].email

    @case_id = case_record

    subject = "Case Registration Completed"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 2-b
  # Case Registration Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_case_registration_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Case Registration Verified"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 3-a
  # Initial Assessment Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_initial_assessment_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #
    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(cpo_users[0])

    user_email = cpo_users[0].email

    @case_id = case_record

    subject = "Initial Assessment Completed"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 3-b
  # Initial Assessment Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_initial_assessment_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Initial Assessment Verified"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 4-a
  # Comprehensive Assessment Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_comprehensive_assessment_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #
    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(cpo_users[0])

    user_email = cpo_users[0].email

    @case_id = case_record

    subject = "Comprehensive Assessment Completed"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 4-b
  # Comprehensive Assessment Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_comprehensive_assessment_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Initial Assessment Verified"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 5-a
  # Case Plan Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_case_plan_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #
    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(cpo_users[0])

    user_email = cpo_users[0].email

    @case_id = case_record

    subject = "Case Plan Completed"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 5-b
  # Case Plan Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_case_plan_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Case Plan Verified"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 6-a
  # Alternative Care Placement Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_alternative_care_placement_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #
    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(cpo_users[0])

    user_email = cpo_users[0].email

    @case_id = case_record

    subject = "Alternative Care Placement Completed"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 6-b
  # Alternative Care Placement | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_alternative_care_placement_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Alternative Care Placement Verified"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 7-a
  # Monitoring and Follow up Sub form | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_monitoring_and_follow_up_subform_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #
    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(cpo_users[0])

    user_email = cpo_users[0].email

    @case_id = case_record

    subject = "Monitoring and Follow up Sub form"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 7-b
  # Monitoring and Follow up Sub form | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_monitoring_and_follow_up_subform_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Monitoring and Follow up Sub form"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8a
  # Case Referred | Mail to some Recipient
  # Case id | SCW/Psychologist Username | Email of Recipient
  def send_case_referred_to_user_notification(case_record, reciever)
    @reciever_name = reciever.user_name
    @case_id = case_record.record_id
    @transfered_by_user_name = case_record["transitioned_by"]

    user_email = reciever.email

    subject = "Message to Referral Recipient"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8b
  # Case Referred | Mail to some Recipient
  # Case id | SCW/Psychologist Username | Email of Recipient
  def send_case_referred_revoked_notification(case_record, reciever)
    @reciever_name = reciever.user_name
    @case_id = case_record.record_id
    @transfered_by_user_name = case_record["transitioned_by"]

    user_email = reciever.email

    subject = "Message to Referral Recipient"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8c
  # Case Referred | Mail to SCW/Psychologist
  # Case id | Referral Partner Username | Email of SCW/Psychologist
  def send_case_referred_accepted_notification(case_record, reciever)
    @reciever_name = reciever.user_name
    @case_id = case_record.record_id
    @transfered_by_user_name = case_record["transitioned_by"]
    sender = User.find_by(user_name: @transfered_by_user_name)
    user_email = sender.email

    subject = "Message to SCW/Psy  Referral Accepted"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8d
  # Case Referred | Mail to SCW/Psychologist
  # Case id | Referral Partner Username | Email of SCW/Psychologist
  def send_case_referred_rejected_notification(case_record, reciever)
    @reciever_name = reciever.user_name
    @case_id = case_record.record_id
    @transfered_by_user_name = case_record.data["transitioned_by"]
    sender = User.find_by(user_name: @transfered_by_user_name)
    user_email = sender.email

    subject = "Message to SCW/Psy  Referral Rejected"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8e
  # Case Referred Response | Mail to SCW/Psychologist
  # Case id | Referral Partner Username | Email of SCW/Psychologist
  def send_case_referred_response_notification(case_record, reciever, sender)
    @reciever_name = reciever.user_name
    @case_id = case_record.record_id
    @transfered_by_user_name = sender.user_name
    user_email = sender.email

    subject = "Message to SCW/Psy Referral Response"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 9-a
  # Case Transfer Completes | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_case_transfer_completes_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #
    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(cpo_users[0])

    user_email = cpo_users[0].email

    @case_id = case_record

    subject = "Monitoring and Follow up Sub form"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 9-b
  # Case Transfer Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_case_transfer_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Monitoring and Follow up Sub form"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 9-c
  # Case Transfer Approved | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_case_transfer_approved_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    return unless assert_notifications_enabled(user)

    user_email = user.email

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Monitoring and Follow up Sub form"

    if user_email.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 11a
  # Case Notes | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username | Workflow Stage
  def send_case_query_notification(case_record, cpo_user)
    @case_id = case_record.data["case_id"]
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)
    user_email = user.email

    @workflow_stage = case_record.data["workflow"]
    @user_name = cpo_user.user_name

    subject = "Case Notes Added to #{@case_id}"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 12a
  # Case Flags | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username | Workflow Stage
  def send_case_flags_notification(case_record, cpo_user)
    @case_id = case_record.data["case_id"]
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)
    user_email = user.email

    @workflow_stage = case_record.data["workflow"]
    @user_name = cpo_user.name
    subject = "Case Flags Added to #{@case_id}"

    if user_email.present?
      mail(to: user_email, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  private

  def assert_notifications_enabled(user)
    (user&.email && user&.send_mail) ||
      Rails.logger.info(
        "Mail not sent. Notifications disabled for #{user&.user_name || 'nil user'}"
      )
  end
end
