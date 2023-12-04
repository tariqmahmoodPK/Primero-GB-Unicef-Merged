# NOTE This file is used for Prevention Graphs

# NOTE Helper Methods for Graphs
module IncidentGraphHelpers
  # Used By:
    # 'Community based Child Protection Committees'
  #
  def get_male_community_based_child_protection_committees_records
    # Male Community Form Attributes
    attributes_to_check = [
      'district_0a62fe4',
      'union_council_fb63727',
      'name_of_the_vc___nc_30531b2',
      'date_of_formation_305cccb',
      'date_of_activation_3cfd0a4',
      'total_members_d8316cb',
      'focal_person_name_30d4f47',
      'focal_person_contact_number_fd5364f',
      'purpose_of_meeting_105d341'
    ]
    # Check if any of the specified attributes is not null.
    Incident.where(attributes_to_check.map { |attr| "data -> '#{attr}' IS NOT NULL" }.join(" OR "))
  end

  # Used By:
    # 'Community based Child Protection Committees'
  #
  def get_female_community_based_child_protection_committees_records
    # Female Community Form Attributes
    attributes_to_check = [
      'district_a3c1609',
      'union_council_af9e8b5',
      'name_of_the_vc___nc_6ceef16',
      'date_of_formation_067097f',
      'date_of_activation_0733524',
      'total_members_619e1a2',
      'focal_person_name_18b1bfc',
      'focal_person_contact_number_362d13c',
      'purpose_of_meeting_1e088ac'
    ]

    # Check if any of the specified attributes is not null.
    Incident.where(attributes_to_check.map { |attr| "data -> '#{attr}' IS NOT NULL" }.join(" OR "))
  end

  # Used By:
    # 'Community Engagement Sessions'
  #
  def get_transgender_participants_records
    Incident.where("data -> 'transgender_9d408e0' IS NOT NULL")
  end

  def get_female_participants_records
    Incident.where("data -> 'female_01b2ffb' IS NOT NULL")
  end

  def get_male_participants_records
    Incident.where("data -> 'male_513bfd8' IS NOT NULL")
  end

  def get_girls_participants_records
    Incident.where("data -> 'girls_f9001ff' IS NOT NULL")
  end

  def get_boys_participants_records
    Incident.where("data -> 'boys_75417f5' IS NOT NULL")
  end

  def get_total_participants_in_the_training_records
    Incident.where("data -> 'total_participants_in_the_training_79cec05' IS NOT NULL")
  end
end
