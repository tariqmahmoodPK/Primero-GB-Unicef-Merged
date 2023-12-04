# NOTE Helper Methods for Graphs
module GraphHelpers
  # Used By:
    # 'Percentage of Children who received Child Protection Services'
    # 'Registered and Closed Cases by Month'
    # 'High Risk Cases by Protection Concern'
    # 'Registered Cases by Protection Concern'
  def get_childern_records(user, is_risk_level_high = nil, open_cases = false)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_cases_assigned_to_specific_user(user, is_risk_level_high, open_cases)
    # View Cases of all Districts (Provincial data)
    when 'CPWC'
      get_cases_assigned_to_specific_location(user, is_risk_level_high, open_cases)
    # View Cases of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_cases_for_particular_user_group(user, is_risk_level_high, open_cases)
    # View Cases Referred to User
    when 'Referral'
      get_cases_referred_to_user(user, is_risk_level_high, open_cases)
    else
      # All Cases that are owned by the users under an Agency and are also owned by a particular location
      get_cases_with_location_and_agency(user, is_risk_level_high, open_cases)
    end
  end

  # View Cases of a User
  def get_cases_assigned_to_specific_user(user, is_risk_level_high = nil, open_cases = false)
    username = user.user_name

    # Search for Records that are 'Owned By'/'Created by' Username
    # And have a 'High Risk Level'/'Significant Harm'
    cases = Child.search do
      with(:owned_by, username)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
    search = Child.search do
      with(:owned_by, username)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # View Cases of all Districts (Provincial data)
  def get_cases_assigned_to_specific_location(user, is_risk_level_high = nil, open_cases = false)
    # User's Location Code
    location_code = user.location

    cases = nil
    search = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      cases = Child.search do
        with(:location_current, location_code)
        with(:status, "open")
        with(:risk_level, 'high') if is_risk_level_high.present?
      end

      search = Child.search do
        with(:location_current, location_code)
        with(:status, "open")
        with(:risk_level, 'high') if is_risk_level_high.present?

        paginate :page => 1, :per_page => cases.total
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:risk_level, 'high') if is_risk_level_high.present?
        with(:status, "open")
      end

      search = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:risk_level, 'high') if is_risk_level_high.present?
        with(:status, "open")

        paginate :page => 1, :per_page => cases.total
      end
    end

    search.results
  end

  # View Cases of Social Case Worker, Psychologist, Child Helpline Operator, Working in his user group.
  def get_cases_for_particular_user_group(cpo_user, is_risk_level_high = nil, open_cases = false)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    cases = Child.search do
      with(:owned_by, usernames)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    # Get Cases that are owned by given Usernames and Also Paginate them.
    search = Child.search do
      with(:owned_by, usernames)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # View Cases Referred to User
  def get_cases_referred_to_user(user, is_risk_level_high = nil, open_cases = false)
    # User's Name, Duh!
    user_name = user.name

    results = []

    # Get all the referred cases and see if the User has any cases referred to him.
    Child.get_referred_cases(open_cases).each do |child|
      if is_risk_level_high.present? && child.risk_level == 'high'
        child.data["assigned_user_names"].each do |referred_user|
          # If referred_user matches the user_name, add the child to results
          results << child if referred_user == user_name
        end
      end
    end

    results
  end

  # Get all Child records where 'assigned_user_names' in not nil
  def get_referred_cases(open_cases = false)
    search = Child.search do
      without(:assigned_user_names, nil)
    end

    search.results
  end

  # All Cases that are owned by the users under an Agency and are also owned by a particular location
  def get_cases_with_location_and_agency(user, is_risk_level_high = nil, open_cases = false)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    # Search for Records
      # That have a 'High Risk Level'/'Significant Harm' and
      # That are either 'Owned By'/'Created by' Username or have the same location as the User.
    cases = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:location_current, location_code)
        with(:status, "open")
      end
    end

    # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
    search = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:location_current, location_code)
        with(:status, "open")
      end

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  def get_percentage(value, count)
    ((value / count.to_f) * 100).round
  end

  # -------------------------------------------------------------------------------------------------

  # Used By:
    # 'Closed Cases by Sex and Reason'
  def get_resolved_cases_for_role(user, is_risk_level_high = nil)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Resolved Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_resolved_cases_of_specific_user(user, is_risk_level_high)
    # View Resolved Cases of all Districts (Provincial data)
    when 'CPWC'
      get_resolved_cases_by_specific_location(user, is_risk_level_high)
    # View Resolved Cases of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_resolved_cases_for_particular_user_group(user, is_risk_level_high)
    # View Resolved Cases Referred to User
    when 'Referral'
      get_resolved_cases_referred_to_user(user, is_risk_level_high)
    else
      # All Resolved Cases that are owned by the users under an Agency and are also owned by a particular location
      get_resolved_cases_with_location_and_agency(user, is_risk_level_high)
    end
  end

  # View Resolved Cases of a User
  def get_resolved_cases_of_specific_user(user , is_risk_level_high = nil)
    username = user.user_name

    # Search for Records that are 'Owned By'/'Created by' Username
    # And are Closed/Resolved
    # And have a 'High Risk Level'/'Significant Harm'

    # NOTE Not checking if the records have any option/value form the 'What is reason for closing this case' Dropdown
    # NOTE As It is assumed that if a case is closed then some option would have been selected.
    # But they can be checked using something like this.
    # any_of do
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_all_met_811860" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_reached_adulthood_490887" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_refuses_services_181533" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "safety_of_child_362513" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "death_of_child_285462" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "other_100182" })
    # end

    cases = Child.search do
      with(:owned_by, username)
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
    search = Child.search do
      with(:owned_by, username)
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # View Resolved Cases of all Districts (Provincial data)
  def get_resolved_cases_by_specific_location(user, is_risk_level_high = nil)
    # User's Location Code
    location_code = user.location

    cases = nil
    search = nil

    # NOTE Not checking if the records have any option/value form the 'What is reason for closing this case' Dropdown
    # NOTE As It is assumed that if a case is closed then some option would have been selected.
    # But they can be checked using something like this.
    # any_of do
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_all_met_811860" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_reached_adulthood_490887" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_refuses_services_181533" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "safety_of_child_362513" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "death_of_child_285462" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "other_100182" })
    # end

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      # Search for Records whose location_current code matches the location code of the User.
      # And are Closed/Resolved
      # And have a 'High Risk Level'/'Significant Harm'
      cases = Child.search do
        with(:location_current, location_code)
        with(:status, "closed")
        with(:risk_level, 'high') if is_risk_level_high.present?
      end

      # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
      search = Child.search do
        with(:location_current, location_code)
        with(:status, "closed")
        with(:risk_level, 'high') if is_risk_level_high.present?

        paginate :page => 1, :per_page => cases.total
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      # Search for Records whose location_current code matches 'KPK'
      # And are Closed/Resolved
      # And have a 'High Risk Level'/'Significant Harm'
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:status, "closed")
        with(:risk_level, 'high') if is_risk_level_high.present?
      end

      # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
      search = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:status, "closed")
        with(:risk_level, 'high') if is_risk_level_high.present?

        paginate :page => 1, :per_page => cases.total
      end
    end

    search.results
  end

  # View Resolved Cases of Users with Roles: Social Case Worker, Psychologist, Child Helpline Operator, That are Working in his UserGroup.
  def get_resolved_cases_for_particular_user_group(cpo_user, is_risk_level_high = nil)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    # NOTE Not checking if the records have any option/value form the 'What is reason for closing this case' Dropdown
    # NOTE As It is assumed that if a case is closed then some option would have been selected.
    # But they can be checked using something like this.
    # any_of do
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_all_met_811860" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_reached_adulthood_490887" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_refuses_services_181533" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "safety_of_child_362513" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "death_of_child_285462" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "other_100182" })
    # end

    # Search for Records that are 'Owned By'/'Created by' Username
    # And are Closed/Resolved
    # And have a 'High Risk Level'/'Significant Harm'
    cases = Child.search do
      with(:owned_by, usernames)
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    # Get Cases that are owned by given Usernames and Also Paginate them.
    # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
    search = Child.search do
      with(:owned_by, usernames)
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # View Resolved Cases Referred to User
  def get_resolved_cases_referred_to_user(user, is_risk_level_high = nil)
    # User's Name, Duh!
    user_name = user.name

    results = []

    # Get all the Resolved referred cases and see if the User has any cases referred to him.
    Child.get_referred_and_resolved_cases.each do |child|
      if is_risk_level_high.present? && child.risk_level == 'high'
        child.data["assigned_user_names"].each do |referred_user|
          # If referred_user matches the user_name, add the child to results
          results << child if referred_user == user_name
        end
      end
    end

    results
  end

  # Get all Resolved Child records where 'assigned_user_names' in not nil
  def get_referred_and_resolved_cases
    # NOTE Not checking if the records have any option/value form the 'What is reason for closing this case' Dropdown
    # NOTE As It is assumed that if a case is closed then some option would have been selected.
    # But they can be checked using something like this.
    # any_of do
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_all_met_811860" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_reached_adulthood_490887" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "child_refuses_services_181533" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "safety_of_child_362513" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "death_of_child_285462" })
    #   with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "other_100182" })
    # end

    search = Child.search do
      without(:assigned_user_names, nil)
      with(:status, "closed")
    end

    search.results
  end

  # All Resolved Cases that are owned by the users under an Agency and are also owned by a particular location
  def get_resolved_cases_with_location_and_agency(user, is_risk_level_high = nil)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    # Search for Records
      # And are Closed/Resolved
      # That have a 'High Risk Level'/'Significant Harm' and
      # That are either 'Owned By'/'Created by' Username or have the same location as the User.
    cases = Child.search do
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:location_current, location_code)
      end
    end

    # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
    search = Child.search do
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:location_current, location_code)
      end

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # -------------------------------------------------------------------------------------------------

  # Used By:
    # 'Cases requiring Alternative Care Placement Services'
  def get_cases_requiring_alternative_care(user, is_risk_level_high = nil)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases requiring Alternative Care Placement Services of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_cases_requiring_alternative_care_services_of_specific_user(user, is_risk_level_high)
    # View Cases requiring Alternative Care Placement Services of all Districts (Provincial data)
    when 'CPWC'
      get_cases_requiring_alternative_care_services_by_specific_location(user, is_risk_level_high)
    # View Cases requiring Alternative Care Placement Services of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_cases_requiring_alternative_care_services_for_particular_user_group(user, is_risk_level_high)
    # View Cases requiring Alternative Care Placement Services Referred to User
    when 'Referral'
      get_cases_requiring_alternative_care_services_referred_to_user(user, is_risk_level_high)
    else
      # All Cases requiring Alternative Care Placement Services that are owned by the users under an Agency and are also owned by a particular location
      get_cases_requiring_alternative_care_services_with_location_and_agency(user, is_risk_level_high)
    end
  end

  # View Cases requiring Alternative Care Placement Services of a User
  def get_cases_requiring_alternative_care_services_of_specific_user(user, is_risk_level_high = nil)
    username = user.user_name

    cases = Child.search do
      with(:owned_by, username)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?

      # NOTE If in the future we want to check for any nationality then we can simply do that with
        # * without(:nationality_b80911e, nil)
      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
      end
    end

    search = Child.search do
      with(:owned_by, username)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
      end

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # View Cases requiring Alternative Care Placement Services of all Districts (Provincial data)
  def get_cases_requiring_alternative_care_services_by_specific_location(user, is_risk_level_high = nil)
    # User's Location Code
    location_code = user.location

    cases = nil
    search = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      cases = Child.search do
        with(:location_current, location_code)
        with(:status, "open")
        with(:risk_level, 'high') if is_risk_level_high.present?

        any_of do
          with(:nationality_b80911e, 'nationality1' ) # Pakistani
          with(:nationality_b80911e, 'nationality2' ) # Afgani
          with(:nationality_b80911e, 'nationality3' ) # Irani
          with(:nationality_b80911e, 'nationality10') # Other
        end
      end

      # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
      search = Child.search do
        with(:location_current, location_code)
        with(:status, "open")
        with(:risk_level, 'high') if is_risk_level_high.present?

        any_of do
          with(:nationality_b80911e, 'nationality1' ) # Pakistani
          with(:nationality_b80911e, 'nationality2' ) # Afgani
          with(:nationality_b80911e, 'nationality3' ) # Irani
          with(:nationality_b80911e, 'nationality10') # Other
        end

        paginate :page => 1, :per_page => cases.total
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      # Search for Records whose location_current code matches 'KPK'
      # And are Closed/Resolved
      # And have a 'High Risk Level'/'Significant Harm'
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:risk_level, 'high') if is_risk_level_high.present?
        with(:status, "open")

        any_of do
          with(:nationality_b80911e, 'nationality1' ) # Pakistani
          with(:nationality_b80911e, 'nationality2' ) # Afgani
          with(:nationality_b80911e, 'nationality3' ) # Irani
          with(:nationality_b80911e, 'nationality10') # Other
        end
      end

      # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
      search = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:risk_level, 'high') if is_risk_level_high.present?
        with(:status, "open")

        any_of do
          with(:nationality_b80911e, 'nationality1' ) # Pakistani
          with(:nationality_b80911e, 'nationality2' ) # Afgani
          with(:nationality_b80911e, 'nationality3' ) # Irani
          with(:nationality_b80911e, 'nationality10') # Other
        end

        paginate :page => 1, :per_page => cases.total
      end
    end

    search.results
  end

  # View Cases requiring Alternative Care Placement Services of User with
  # Roles: Social Case Worker, Psychologist, Child Helpline Operator, and  That are Working in his UserGroup.
  def get_cases_requiring_alternative_care_services_for_particular_user_group(cpo_user, is_risk_level_high = nil)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    cases = Child.search do
      with(:owned_by, usernames)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
      end
    end

    # Get Cases that are owned by given Usernames and Also Paginate them.
    search = Child.search do
      with(:owned_by, usernames)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
      end

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # View Cases requiring Alternative Care Placement Services Referred to User
  def get_cases_requiring_alternative_care_services_referred_to_user(user, is_risk_level_high = nil)
    # User's Name, Duh!
    user_name = user.name

    results = []

    # Get all the referred cases and see if the User has any cases referred to him.
    Child.get_referred_cases_requiring_alternative_care_services.each do |child|
      if is_risk_level_high.present? && child.risk_level == 'high'
        child.data["assigned_user_names"].each do |referred_user|
          # If referred_user matches the user_name, add the child to results
          results << child if referred_user == user_name
        end
      end
    end

    results
  end

  # Get all Child records requiring Alternative Care Placement Services where 'assigned_user_names' in not nil
  def get_referred_cases_requiring_alternative_care_services
    search = Child.search do
      without(:assigned_user_names, nil)
      with(:status, "open")

      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
      end
    end

    search.results
  end

  # All Cases requiring Alternative Care Placement Services that are owned by the users under an Agency and are also owned by a particular location
  def get_cases_requiring_alternative_care_services_with_location_and_agency(user, is_risk_level_high = nil)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    cases = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?
      with(:status, "open")

      all_of do
        any_of do
          with(:owned_by, usernames)
          with(:location_current, location_code)
        end

        any_of do
          with(:nationality_b80911e, 'nationality1')   # Pakistani
          with(:nationality_b80911e, 'nationality2')   # Afgani
          with(:nationality_b80911e, 'nationality3')   # Irani
          with(:nationality_b80911e, 'nationality10')  # Other
        end
      end
    end

    # Needed to panginate using the Total Number of Cases. That is why, Had to search twice.
    search = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?
      with(:status, "open")

      all_of do
        any_of do
          with(:owned_by, usernames)
          with(:location_current, location_code)
        end

        any_of do
          with(:nationality_b80911e, 'nationality1')   # Pakistani
          with(:nationality_b80911e, 'nationality2')   # Afgani
          with(:nationality_b80911e, 'nationality3')   # Irani
          with(:nationality_b80911e, 'nationality10')  # Other
        end
      end

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # -------------------------------------------------------------------------------------------------

  # Used By:
    # 'Cases Referrals (To Agency)'
  def get_cases_referred_to_agencies(user, is_risk_level_high = nil, open_cases = false)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Open Referrals Cases Where Referred to Agency, Owned by a Specific User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_cases_referred_to_agencies_of_specific_user(user, is_risk_level_high, open_cases)
    # View Open Referrals cases Where Referred to Agency, Of all Districts (Provincial data)
    when 'CPWC'
      get_cases_referred_to_agencies_by_specific_location(user, is_risk_level_high, open_cases)
    # View Open Referrals Cases Where Referred to Agency,
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_cases_referred_to_agencies_for_particular_user_group(user, is_risk_level_high, open_cases)
    # View Open Referrals Cases Where Referred to Agency that Referred to User
    when 'Referral'
      get_cases_referred_to_agencies_referred_to_user(user, is_risk_level_high, open_cases)
    else
      # All Open Referrals Cases Where Referred to Agency that are owned by the users under an Agency and are also owned by a particular location
      get_cases_referred_to_agencies_with_location_and_agency(user, is_risk_level_high, open_cases)
    end
  end

  # View Open Referrals cases Where Referred to Agency, Owned by a Specific User
  def get_cases_referred_to_agencies_of_specific_user(user, is_risk_level_high = nil, open_cases = false)
    username = user.user_name

    search = Child.search do
      with(:owned_by, username)
      with(:status, "open")
      with(:risk_level, 'high') if is_risk_level_high.present?
      without(:assigned_user_names, nil)
    end

    search.results

    get_filter_cases_referred_to_agencies_from_referred_cases(search.results)
  end

  # View Open Referrals cases Where Referred to Agency, Of all Districts (Provincial data)
  def get_cases_referred_to_agencies_by_specific_location(user, is_risk_level_high = nil, open_cases = false)
    # User's Location Code
    location_code = user.location

    search = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      search = Child.search do
        with(:location_current, location_code)
        with(:risk_level, 'high') if is_risk_level_high.present?
        without(:assigned_user_names, nil)
        with(:status, "open")
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      search = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:risk_level, 'high') if is_risk_level_high.present?
        without(:assigned_user_names, nil)
        with(:status, "open")
      end
    end

    get_filter_cases_referred_to_agencies_from_referred_cases(search.results)
  end

  # View Open Referrals cases Where Referred to Agency, Users with Roles:Social Case Worker, Psychologist, Child Helpline Operator, That are Working in his UserGroup.
  def get_cases_referred_to_agencies_for_particular_user_group(cpo_user, is_risk_level_high = nil, open_cases = false)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    # Get Cases that are owned by given Usernames and Also Paginate them.
    search = Child.search do
      with(:owned_by, usernames)
      with(:risk_level, 'high') if is_risk_level_high.present?
      without(:assigned_user_names, nil)
      with(:status, "open")
    end

    get_filter_cases_referred_to_agencies_from_referred_cases(search.results)
  end

  # View Open Referrals Cases Where Referred to Agency that Referred to User
  def get_cases_referred_to_agencies_referred_to_user(user, is_risk_level_high = nil, open_cases = false)
    # User's Name, Duh!
    user_name = user.name

    referred_cases = []

    # Get all the referred cases and see if the User has any cases referred to him.
    Child.get_referred_cases(open_cases).each do |child|
      if is_risk_level_high.present? && child.risk_level == 'high'
        child.data["assigned_user_names"].each do |referred_user|
          # If referred_user matches the user_name, add the child to referred_cases
          referred_cases << child if referred_user == user_name
        end
      end
    end

    get_filter_cases_referred_to_agencies_from_referred_cases(referred_cases)
  end

  # All Open Referrals Cases Where Referred to Agency that are owned by the users under an Agency and are also owned by a particular location
  def get_cases_referred_to_agencies_with_location_and_agency(user, is_risk_level_high = nil, open_cases = false)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    search = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?
      without(:assigned_user_names, nil)
      with(:status, "open")

      any_of do
        with(:owned_by, usernames)
        with(:location_current, location_code)

      end
    end

    get_filter_cases_referred_to_agencies_from_referred_cases(search.results)
  end

  def get_filter_cases_referred_to_agencies_from_referred_cases(referred_cases)
    referred_cases_to_agency = []

    referred_cases.each do |child|
      agencies_assigned = child.data["assigned_user_names"].map do |refer|
        user = User.find_by(user_name: refer)
        user.agency_id ? Agency.find(user.agency_id) : nil
      end.compact

      if agencies_assigned.any?
        # Add this child to the array if it's assigned to at least one agency
        referred_cases_to_agency << child
      end
    end

    referred_cases_to_agency
  end

  # -------------------------------------------------------------------------------------------------

  #  Registered and Closed Cases by Month
  def hash_return_for_month_wise_api
    month_list = {
      "Jan" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Feb" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Mar" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Apr" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "May" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Jun" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Jul" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Aug" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Sep" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Oct" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Nov" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
      "Dec" => { "male" => 0, "female" => 0, "transgender" => 0, "total" => 0 },
    }

    month_list
  end

  # -------------------------------------------------------------------------------------------------

  # Used by:
    # 'Cases at a Glance'
  #
  def get_case_records(user)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_case_records_assigned_to_specific_user(user)
    # View Cases of all Districts (Provincial data)
    when 'CPWC'
      get_case_records_assigned_to_specific_location(user)
    # View Cases of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_case_records_for_particular_user_group(user)
    # View Cases Referred to User
    when 'Referral'
      get_case_records_referred_to_user(user)
    else
      # All Cases that are owned by the users under an Agency and are also owned by a particular location
      get_case_records_with_location_and_agency(user)
    end
  end

  def get_case_records_assigned_to_specific_user(user)
    username = user.user_name

    cases = Child.search do
      with(:owned_by, username) # Assigned to Me

      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
        with(:status, "open") # Registered
        with(:status, "closed") # Closed Cases
        with(:risk_level, 'high') # High
        with(:risk_level, 'medium') # Medium
        with(:risk_level, 'low') # Low
      end
    end

    cases.results
  end

  def get_case_records_assigned_to_specific_location(user)
    username = user.user_name
    # User's Location Code
    location_code = user.location

    cases = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      cases = Child.search do
        with(:location_current, location_code)
        any_of do
          with(:nationality_b80911e, 'nationality1' ) # Pakistani
          with(:nationality_b80911e, 'nationality2' ) # Afgani
          with(:nationality_b80911e, 'nationality3' ) # Irani
          with(:nationality_b80911e, 'nationality10') # Other
          with(:status, "open") # Registered
          with(:status, "closed") # Closed Cases
          with(:risk_level, 'high') # High
          with(:risk_level, 'medium') # Medium
          with(:risk_level, 'low') # Low
        end
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        any_of do
          with(:nationality_b80911e, 'nationality1' ) # Pakistani
          with(:nationality_b80911e, 'nationality2' ) # Afgani
          with(:nationality_b80911e, 'nationality3' ) # Irani
          with(:nationality_b80911e, 'nationality10') # Other
          with(:status, "open") # Registered
          with(:status, "closed") # Closed Cases
          with(:risk_level, 'high') # High
          with(:risk_level, 'medium') # Medium
          with(:risk_level, 'low') # Low
        end
      end
    end

    cases.results
  end

  def get_case_records_for_particular_user_group(cpo_user)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    cases = Child.search do
      with(:owned_by, usernames)
      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
        with(:status, "open") # Registered
        with(:status, "closed") # Closed Cases
        with(:risk_level, 'high') # High
        with(:risk_level, 'medium') # Medium
        with(:risk_level, 'low') # Low
      end
    end

    cases.results
  end

  def get_case_records_referred_to_user(user)
    user_name = user.name

    cases = Child.search do
      without(:assigned_user_names, nil)
      any_of do
        with(:nationality_b80911e, 'nationality1' ) # Pakistani
        with(:nationality_b80911e, 'nationality2' ) # Afgani
        with(:nationality_b80911e, 'nationality3' ) # Irani
        with(:nationality_b80911e, 'nationality10') # Other
        with(:status, 'open') # Registered
        with(:status, 'closed') # Closed Cases
        with(:risk_level, 'high') # High
        with(:risk_level, 'medium') # Medium
        with(:risk_level, 'low') # Low
        any_of do
          with(:assigned_user_names, user_name)
        end
      end
    end

    cases.results
  end

  def get_case_records_with_location_and_agency(user)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    cases = Child.search do
      all_of do
        any_of do
          with(:owned_by, usernames)
          with(:location_current, location_code)
        end

        any_of do
          with(:nationality_b80911e, 'nationality1' ) # Pakistani
          with(:nationality_b80911e, 'nationality2' ) # Afgani
          with(:nationality_b80911e, 'nationality3' ) # Irani
          with(:nationality_b80911e, 'nationality10') # Other
          with(:status, "open") # Registered
          with(:status, "closed") # Closed Cases
          with(:risk_level, 'high') # High
          with(:risk_level, 'medium') # Medium
          with(:risk_level, 'low') # Low
        end
      end
    end

    cases.results
  end

  # -------------------------------------------------------------------------------------------------

  # Used by:
    # 'Cases Source'
  #
  def get_case_records_with_sources(user)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_cases_with_sources_assigned_to_specific_user(user)
    # View Cases of all Districts (Provincial data)
    when 'CPWC'
      get_cases_with_sources_assigned_to_specific_location(user)
    # View Cases of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_cases_with_sources_for_particular_user_group(user)
    # View Cases Referred to User
    when 'Referral'
      get_cases_with_sources_referred_to_user(user)
    else
      # All Cases that are owned by the users under an Agency and are also owned by a particular location
      get_cases_with_sources_with_location_and_agency(user)
    end
  end

  def get_cases_with_sources_assigned_to_specific_user(user)
    username = user.user_name

    cases = Child.search do
      with(:owned_by, username)
      without(:source_of_report_25665ab, nil)
    end

    cases.results
  end

  def get_cases_with_sources_assigned_to_specific_location(user)
    username = user.user_name
    # User's Location Code
    location_code = user.location

    cases = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      cases = Child.search do
        with(:location_current, location_code)
        without(:source_of_report_25665ab, nil)
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        without(:source_of_report_25665ab, nil)
      end
    end

    cases.results
  end

  def get_cases_with_sources_for_particular_user_group(cpo_user)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    cases = Child.search do
      with(:owned_by, usernames)
      without(:source_of_report_25665ab, nil)
    end

    cases.results
  end

  def get_cases_with_sources_referred_to_user(user)
    user_name = user.name

    cases = Child.search do
      without(:assigned_user_names, nil)
      all_of do
        without(:source_of_report_25665ab, nil)
        with(:assigned_user_names, user_name)
      end
    end

    cases.results
  end

  def get_cases_with_sources_with_location_and_agency(user)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    cases = Child.search do
      all_of do
        any_of do
          with(:owned_by, usernames)
          with(:location_current, location_code)
        end

        any_of do
          without(:source_of_report_25665ab, nil)
        end
      end
    end

    cases.results
  end

  # -------------------------------------------------------------------------------------------------

  # Used by:
    # 'Police Cases'
  #
  def get_police_case_records(user)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_police_cases_assigned_to_specific_user(user)
    # View Cases of all Districts (Provincial data)
    when 'CPWC'
      get_police_cases_assigned_to_specific_location(user)
    # View Cases of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_police_cases_for_particular_user_group(user)
    # View Cases Referred to User
    when 'Referral'
      get_police_cases_referred_to_user(user)
    else
      # All Cases that are owned by the users under an Agency and are also owned by a particular location
      get_police_cases_with_location_and_agency(user)
    end
  end

  def get_police_cases_assigned_to_specific_user(user)
    username = user.user_name

    cases = Child.search do
      with(:owned_by, username)
      with(:status, "open")
      with(:source_of_report_25665ab, "police_646813")
    end

    cases.results
  end

  def get_police_cases_assigned_to_specific_location(user)
    username = user.user_name
    # User's Location Code
    location_code = user.location

    cases = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      cases = Child.search do
        with(:location_current, location_code)
        with(:status, "open")
        with(:source_of_report_25665ab, "police_646813")
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:status, "open")
        with(:source_of_report_25665ab, "police_646813")
      end
    end

    cases.results
  end

  def get_police_cases_for_particular_user_group(cpo_user)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    cases = Child.search do
      with(:owned_by, usernames)
      with(:status, "open")
      with(:source_of_report_25665ab, "police_646813")
    end

    cases.results
  end

  def get_police_cases_referred_to_user(user)
    user_name = user.name

    cases = Child.search do
      without(:assigned_user_names, nil)
      all_of do
        with(:status, "open")
        with(:source_of_report_25665ab, "police_646813")
        with(:assigned_user_names, user_name)
      end
    end

    cases.results
  end

  def get_police_cases_with_location_and_agency(user)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    cases = Child.search do
      all_of do
        any_of do
          with(:owned_by, usernames)
          with(:location_current, location_code)
        end

        all_of do
          with(:status, "open")
          with(:source_of_report_25665ab, "police_646813")
        end
      end
    end

    cases.results
  end

  # -------------------------------------------------------------------------------------------------

  # Used by:
    # 'Cases Requiring Special Consideration'
  #
  def get_special_consideration_case_records(user)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_special_consideration_cases_assigned_to_specific_user(user)
    # View Cases of all Districts (Provincial data)
    when 'CPWC'
      get_special_consideration_cases_assigned_to_specific_location(user)
    # View Cases of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_special_consideration_cases_for_particular_user_group(user)
    # View Cases Referred to User
    when 'Referral'
      get_special_consideration_cases_referred_to_user(user)
    else
      # All Cases that are owned by the users under an Agency and are also owned by a particular location
      get_special_consideration_cases_with_location_and_agency(user)
    end
  end

  def get_special_consideration_cases_assigned_to_specific_user(user)
    username = user.user_name

    cases = Child.search do
      with(:owned_by, username)
      with(:status, "open")

      any_of do
        with(:does_the_child_belong_to_an_ethnic_minority__cddc53f, "true")
        with(:does_the_child_have_any_disability__ef809a3, "true")
        with(:beneficiary_of_social_protection_programs__b2367d9, "bisp_146081") # BISP
        with(:beneficiary_of_social_protection_programs__b2367d9, "ehsaas_820053") # Ehsaas
        with(:beneficiary_of_social_protection_programs__b2367d9, "other_214066") # Other
        with(:parent_guardian_b481d19, "biological_father_219674")
        with(:status_d359d3a, "dead_765780")
        with(:nationality_b80911e, "nationality2") # Afghani
        with(:free_legal_support__through_pro_bono_lawyer__6e227bc, "true")
        with(:source_of_report_25665ab, "other_province_556823")
      end
    end

    cases.results
  end

  def get_special_consideration_cases_assigned_to_specific_location(user)
    username = user.user_name
    # User's Location Code
    location_code = user.location

    cases = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      cases = Child.search do
        with(:location_current, location_code)
        with(:status, "open")
        any_of do
          with(:does_the_child_belong_to_an_ethnic_minority__cddc53f, "true")
          with(:does_the_child_have_any_disability__ef809a3, "true")
          with(:beneficiary_of_social_protection_programs__b2367d9, "bisp_146081") # BISP
          with(:beneficiary_of_social_protection_programs__b2367d9, "ehsaas_820053") # Ehsaas
          with(:beneficiary_of_social_protection_programs__b2367d9, "other_214066") # Other
          with(:parent_guardian_b481d19, "biological_father_219674")
          with(:status_d359d3a, "dead_765780")
          with(:nationality_b80911e, "nationality2") # Afghani
          with(:free_legal_support__through_pro_bono_lawyer__6e227bc, "true")
          with(:source_of_report_25665ab, "other_province_556823")
        end
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:status, "open")
        any_of do
          with(:does_the_child_belong_to_an_ethnic_minority__cddc53f, "true")
          with(:does_the_child_have_any_disability__ef809a3, "true")
          with(:beneficiary_of_social_protection_programs__b2367d9, "bisp_146081") # BISP
          with(:beneficiary_of_social_protection_programs__b2367d9, "ehsaas_820053") # Ehsaas
          with(:beneficiary_of_social_protection_programs__b2367d9, "other_214066") # Other
          with(:parent_guardian_b481d19, "biological_father_219674")
          with(:status_d359d3a, "dead_765780")
          with(:nationality_b80911e, "nationality2") # Afghani
          with(:free_legal_support__through_pro_bono_lawyer__6e227bc, "true")
          with(:source_of_report_25665ab, "other_province_556823")
        end
      end
    end

    cases.results
  end

  def get_special_consideration_cases_for_particular_user_group(cpo_user)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

    cases = Child.search do
      with(:owned_by, usernames)
      with(:status, "open")
      any_of do
        with(:does_the_child_belong_to_an_ethnic_minority__cddc53f, "true")
        with(:does_the_child_have_any_disability__ef809a3, "true")
        with(:beneficiary_of_social_protection_programs__b2367d9, "bisp_146081") # BISP
        with(:beneficiary_of_social_protection_programs__b2367d9, "ehsaas_820053") # Ehsaas
        with(:beneficiary_of_social_protection_programs__b2367d9, "other_214066") # Other
        with(:parent_guardian_b481d19, "biological_father_219674")
        with(:status_d359d3a, "dead_765780")
        with(:nationality_b80911e, "nationality2") # Afghani
        with(:free_legal_support__through_pro_bono_lawyer__6e227bc, "true")
        with(:source_of_report_25665ab, "other_province_556823")
      end
    end

    cases.results
  end

  def get_special_consideration_cases_referred_to_user(user)
    user_name = user.name

    cases = Child.search do
      without(:assigned_user_names, nil)
      all_of do
        with(:status, "open")
        with(:source_of_report_25665ab, "police_646813")
        any_of do
          with(:does_the_child_belong_to_an_ethnic_minority__cddc53f, "true")
          with(:does_the_child_have_any_disability__ef809a3, "true")
          with(:beneficiary_of_social_protection_programs__b2367d9, "bisp_146081") # BISP
          with(:beneficiary_of_social_protection_programs__b2367d9, "ehsaas_820053") # Ehsaas
          with(:beneficiary_of_social_protection_programs__b2367d9, "other_214066") # Other
          with(:parent_guardian_b481d19, "biological_father_219674")
          with(:status_d359d3a, "dead_765780")
          with(:nationality_b80911e, "nationality2") # Afghani
          with(:free_legal_support__through_pro_bono_lawyer__6e227bc, "true")
          with(:source_of_report_25665ab, "other_province_556823")
        end
      end
    end

    cases.results
  end

  def get_special_consideration_cases_with_location_and_agency(user)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    cases = Child.search do
      all_of do
        any_of do
          with(:owned_by, usernames)
          with(:location_current, location_code)
        end

        all_of do
          with(:status, "open")
          any_of do
            with(:does_the_child_belong_to_an_ethnic_minority__cddc53f, "true")
            with(:does_the_child_have_any_disability__ef809a3, "true")
            with(:beneficiary_of_social_protection_programs__b2367d9, "bisp_146081") # BISP
            with(:beneficiary_of_social_protection_programs__b2367d9, "ehsaas_820053") # Ehsaas
            with(:beneficiary_of_social_protection_programs__b2367d9, "other_214066") # Other
            with(:parent_guardian_b481d19, "biological_father_219674")
            with(:status_d359d3a, "dead_765780")
            with(:nationality_b80911e, "nationality2") # Afghani
            with(:free_legal_support__through_pro_bono_lawyer__6e227bc, "true")
            with(:source_of_report_25665ab, "other_province_556823")
          end
        end
      end
    end

    cases.results
  end

  # -------------------------------------------------------------------------------------------------

end
