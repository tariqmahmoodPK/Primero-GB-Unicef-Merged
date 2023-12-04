# frozen_string_literal: true

# API for fetching the aggregate statistics backing the dashboards
class Api::V2::DashboardsController < ApplicationApiController
  def index
    current_user.user_groups.load
    @dashboards = current_user.role.dashboards
    indicators = @dashboards.map(&:indicators).flatten
    @indicator_stats = IndicatorQueryService.query(indicators, current_user)
  end

  # 'Percentage of Children who received Child Protection Services' Graph
  def percentage_children_received_child_protection_services
    @stats = Child.percentage_children_received_child_protection_services_stats(current_user)
  end

  def get_child_statuses
    @statuses = Child.get_child_statuses(current_user)
  end

  # 'Closed Cases by Sex and Reason' Graph
  def resolved_cases_by_gender_and_reason
    @stats = Child.resolved_cases_by_gender_and_reason_stats(current_user)

    # Properly format the stats to use on the React Component
    lookup_values = Lookup.reason_for_closing_case_values

    closed_cases_by_sex_and_reason = {}

    @stats.each do |key, value|
      # Find the corresponding entry in the lookup_values array
      lookup_entry = lookup_values.find { |entry| entry["id"] == key.to_s }

      if lookup_entry
        # Get the English label from the lookup entry
        english_label = lookup_entry["display_text"]["en"]
        # Add the English label as a new key in the closed_cases_by_sex_and_reason hash
        closed_cases_by_sex_and_reason[english_label] = value
      end
    end

    # The new stats format is like this:
    # {
    #   "Case goals all met" => {:male=>0, :female=>0, :transgender=>0},
    #   "Case goals substantially met and there is no further child protection concern" => {:male=>0, :female=>0, :transgender=>0},
    #   "Child reached adulthood" => {:male=>0, :female=>0, :transgender=>0},
    #   "Child refuses services" => {:male=>0, :female=>0, :transgender=>0},
    #   "Safety of child" => {:male=>0, :female=>0, :transgender=>0},
    #   "Death of child" => {:male=>0, :female=>0, :transgender=>0},
    #   "Other" => {:male=>0, :female=>0, :transgender=>0}
    # }

    @stats = closed_cases_by_sex_and_reason
  end

  # 'Cases Referrals (To Agency)' Graph
  def cases_referrals_to_agency
    @stats = Child.cases_referrals_to_agency_stats(current_user)
  end

  # 'Cases requiring Alternative Care Placement Services' Graph
  def alternative_care_placement_by_gender
    @stats = Child.alternative_care_placement_by_gender(current_user)

    # Properly format the stats to use on the React Component
    lookup_values = Lookup.nationality_lookup_values

    nationalities = {}

    @stats.each do |key, value|
      # Find the corresponding entry in the lookup_values array
      lookup_entry = lookup_values.find { |entry| entry["id"] == key.to_s }

      if lookup_entry
        # Get the English label from the lookup entry
        english_label = lookup_entry["display_text"]["en"]
        # Add the English label as a new key in the nationalities hash
        nationalities[english_label] = value
      end
    end

    # The new stats format is like this:
    # {
    #   "Pakistani" => {:male=>0, :female=>0, :transgender=>0},
    #   "Afghan"    => {:male=>0, :female=>0, :transgender=>0},
    #   "Iranian"   => {:male=>0, :female=>0, :transgender=>0},
    #   "Other"     => {:male=>0, :female=>0, :transgender=>0},
    # }

    @stats = nationalities
  end

  # 'Registered and Closed Cases by Month' Graph
  def month_wise_registered_and_resolved_cases_stats
    @stats = Child.month_wise_registered_and_resolved_cases(current_user)
  end

  # 'High Risk Cases by Protection Concern' Graph
  def high_risk_cases_by_protection_concern
    @stats = Child.high_risk_cases_by_protection_concern_stats(current_user)

    # Properly format the stats to use on the React Component
    lookup_values = Lookup.protection_concerns_values

    concerns = {}

    @stats.each do |key, value|
      # Find the corresponding entry in the lookup_values array
      lookup_entry = lookup_values.find { |entry| entry["id"] == key.to_s }

      if lookup_entry
        # Get the English label from the lookup entry
        english_label = lookup_entry["display_text"]["en"]
        # Add the English label as a new key in the concerns hash
        concerns[english_label] = value
      end
    end

    # The new stats format is like this:
    # {
    #   "Violence" =>            {:cases => 0, :percentage => 0},
    #   "Exploitation" =>        {:cases => 0, :percentage => 0},
    #   "Neglect" =>             {:cases => 0, :percentage => 0},
    #   "Harmful practice(s)" => {:cases => 0, :percentage => 0},
    #   "Abuse" =>               {:cases => 0, :percentage => 0},
    #   "Other" =>               {:cases => 0, :percentage => 0}
    # }

    @stats = concerns
  end

  # 'Registered Cases by Protection Concern' Graph
  def registered_cases_by_protection_concern
    @stats = Child.registered_cases_by_protection_concern_stats(current_user)

    # Properly format the stats to use on the React Component
    lookup_values = Lookup.protection_concerns_values

    concerns = {}

    @stats.each do |key, value|
      # Find the corresponding entry in the lookup_values array
      lookup_entry = lookup_values.find { |entry| entry["id"] == key.to_s }

      if lookup_entry
        # Get the English label from the lookup entry
        english_label = lookup_entry["display_text"]["en"]
        # Add the English label as a new key in the concerns hash
        concerns[english_label] = value
      end
    end

    # The new stats format is like this:
    # {
    #   "Violence" =>            { male: 0, female: 0, transgender: 0 },
    #   "Exploitation" =>        { male: 0, female: 0, transgender: 0 },
    #   "Neglect" =>             { male: 0, female: 0, transgender: 0 },
    #   "Harmful practice(s)" => { male: 0, female: 0, transgender: 0 },
    #   "Abuse" =>               { male: 0, female: 0, transgender: 0 },
    #   "Other" =>               { male: 0, female: 0, transgender: 0 }
    # }

    @stats = concerns
  end

  # 'Community based Child Protection Committees'
  def community_based_child_protection_committees
    @stats = Incident.community_based_child_protection_committees_stats(current_user)
  end

  # 'Community Engagement Sessions'
  def community_engagement_sessions
    @stats = Incident.community_engagement_sessions_stats(current_user)
  end

  # 'Cases at a Glance'
  def cases_at_a_glance
    @stats = Child.cases_at_a_glance_stats(current_user)
  end

  # 'Cases Source'
  def cases_source
    @stats = Child.cases_source_stats(current_user)
  end

  # 'Custody with Court Order'
  def custody_with_court_order
    @stats = Child.custody_with_court_order_stats(current_user)
  end

  # 'Police Cases'
  def police_cases
    @stats = Child.police_cases_stats(current_user)
  end

  # 'Cases Requiring Special Consideration'
  def cases_requiring_special_consideration
    @stats = Child.cases_requiring_special_consideration_stats(current_user)
  end
end
