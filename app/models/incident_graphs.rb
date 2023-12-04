# NOTE This file is used for Prevention Graphs

# NOTE All the methods that return the statistics for each of the Prevention Graphs

module IncidentGraphs
  # 'Community based Child Protection Committees'
  def community_based_child_protection_committees_stats(user)
    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'CPO',
      'CP Manager'
    ]

    # Counters for calculating the number of participents for each type of paritcipant, and the total participents
    stats = {
      "Male Commitees"   => 0,
      "Female Commitees" => 0,
      "Total Commitees"  => 0
    }

    # All Community Engagement Sessions records, Records that have Incident.data["community_engagement_sessions"].present
    male_commitees = Incident.get_male_community_based_child_protection_committees_records
    female_commitees = Incident.get_female_community_based_child_protection_committees_records

    stats["Male Commitees"] = male_commitees.count
    stats["Female Commitees"] = female_commitees.count

    stats["Total Commitees"]  = stats["Male Commitees"] + stats["Female Commitees"]

    stats
  end

  # 'Community Engagement Sessions'
  def community_engagement_sessions_stats(user)
    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'CPO',
      'CP Manager'
    ]

    boys_participants = Incident.get_boys_participants_records
    girl_participants = Incident.get_girls_participants_records
    male_participants = Incident.get_male_participants_records
    female_participants = Incident.get_female_participants_records
    transgender_participants = Incident.get_transgender_participants_records
    total_participants = Incident.get_total_participants_in_the_training_records

    num_of_boys_participants        = boys_participants.sum { |record| record.data['boys_75417f5'] }
    num_of_girl_participants        = girl_participants.sum { |record| record.data['girls_f9001ff'] }
    num_of_male_participants        = male_participants.sum { |record| record.data['male_513bfd8'] }
    num_of_female_participants      = female_participants.sum { |record| record.data['female_01b2ffb'] }
    num_of_transgender_participants = transgender_participants.sum { |record| record.data['transgender_9d408e0'] }
    total_num_of_participants       = total_participants.sum { |record| record.data['total_participants_in_the_training_79cec05'] }

    # Counters for calculating the number of participents for each type of paritcipant, and the total participents
    stats = {
      num_of_boys_participants:        num_of_boys_participants,
      num_of_girl_participants:        num_of_girl_participants,
      num_of_male_participants:        num_of_male_participants,
      num_of_female_participants:      num_of_female_participants,
      num_of_transgender_participants: num_of_transgender_participants,
      total_num_of_participants:       total_num_of_participants,
    }

    formatted_stats = {
      "Number of Boy Participants"         => stats[:num_of_boys_participants       ],
      "Number of Girl Participants"        => stats[:num_of_girl_participants       ],
      "Number of Male Participants"        => stats[:num_of_male_participants       ],
      "Number of Female Participants"      => stats[:num_of_female_participants     ],
      "Number of Transgender Participants" => stats[:num_of_transgender_participants],
      "Total Number of Participants"       => stats[:total_num_of_participants      ],
    }

    formatted_stats
  end
end
