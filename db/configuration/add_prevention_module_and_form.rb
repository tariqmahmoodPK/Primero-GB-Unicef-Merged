# frozen_string_literal: true

ActiveJob::Base.queue_adapter = :async

puts "\nCreating Prevention Form LookUp !!!!"

# Create the "Prevention Forms" Form Group that woudl use Prevention Module
Lookup.create_or_update!(
  unique_id:          'lookup-form-group-pc-case',
  name_en:            'Form Groups - PC Case',
  lookup_values_en: [
    {
      id:           'prevention_forms',
      display_text: 'Prevention Forms'
    }
  ].map(&:with_indifferent_access)
)

# Fields Map
field_map = {
  'fields' => [
    { 'source' => [ 'incident_details' , 'pc_incident_identification_violence'        ], 'target' => 'pc_incident_identification_violence'        },
    { 'source' => [ 'incident_details' , 'incident_date'                              ], 'target' => 'incident_date'                              },
    { 'source' => [ 'incident_details' , 'pc_incident_location_type'                  ], 'target' => 'pc_incident_location_type'                  },
    { 'source' => [ 'incident_details' , 'pc_incident_location_type_other'            ], 'target' => 'pc_incident_location_type_other'            },
    { 'source' => [ 'incident_details' , 'incident_location'                          ], 'target' => 'incident_location'                          },
    { 'source' => [ 'incident_details' , 'pc_incident_timeofday'                      ], 'target' => 'pc_incident_timeofday'                      },
    { 'source' => [ 'incident_details' , 'pc_incident_timeofday_actual'               ], 'target' => 'pc_incident_timeofday_actual'               },
    { 'source' => [ 'incident_details' , 'pc_incident_violence_type'                  ], 'target' => 'pc_incident_violence_type'                  },
    { 'source' => [ 'incident_details' , 'pc_incident_previous_incidents'             ], 'target' => 'pc_incident_previous_incidents'             },
    { 'source' => [ 'incident_details' , 'pc_incident_previous_incidents_description' ], 'target' => 'pc_incident_previous_incidents_description' },
    { 'source' => [ 'incident_details' , 'pc_incident_abuser_name'                    ], 'target' => 'pc_incident_abuser_name'                    },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_nationality'        ], 'target' => 'pc_incident_perpetrator_nationality'        },
    { 'source' => [ 'incident_details' , 'perpetrator_sex'                            ], 'target' => 'perpetrator_sex'                            },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_age'                ], 'target' => 'pc_incident_perpetrator_age'                },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_national_id_no'     ], 'target' => 'pc_incident_perpetrator_national_id_no'     },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_other_id_type'      ], 'target' => 'pc_incident_perpetrator_other_id_type'      },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_other_id_no'        ], 'target' => 'pc_incident_perpetrator_other_id_no'        },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_marital_status'     ], 'target' => 'pc_incident_perpetrator_marital_status'     },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_occupation'         ], 'target' => 'pc_incident_perpetrator_occupation'         },
    { 'source' => [ 'incident_details' , 'pc_incident_perpetrator_relationship'       ], 'target' => 'pc_incident_perpetrator_relationship'       },
    { 'source' => [ 'age'                ] , 'target' => 'age'                },
    { 'source' => [ 'sex'                ] , 'target' => 'pc_sex'             },
    { 'source' => [ 'nationality'        ] , 'target' => 'pc_nationality'     },
    { 'source' => [ 'national_id_no'     ] , 'target' => 'national_id_no'     },
    { 'source' => [ 'other_id_type'      ] , 'target' => 'other_id_type'      },
    { 'source' => [ 'other_id_no'        ] , 'target' => 'other_id_no'        },
    { 'source' => [ 'maritial_status'    ] , 'target' => 'maritial_status'    },
    { 'source' => [ 'educational_status' ] , 'target' => 'educational_status' },
    { 'source' => [ 'occupation'         ] , 'target' => 'occupation'         },
    { 'source' => [ 'disability_type'    ] , 'target' => 'pc_disability_type' },
    { 'source' => [ 'owned_by'           ] , 'target' => 'owned_by'           }
  ],
  'map_to' => 'primeromodule-pc'
}

# Module Options
module_options = {
  'allow_searchable_ids'             => true,
  'use_workflow_case_plan'           => true,
  'use_workflow_assessment'          => false,
  'reporting_location_filter'        => true,
  'workflow_status_indicator'        => true,
  'use_workflow_service_implemented' => true
}

puts "\nCreating Prevention Components Module !!!!"

# Create a new PrimeroModule record
prevention_module = PrimeroModule.create_or_update!(
  unique_id:               'primeromodule-pc',
  primero_program:          PrimeroProgram.find_by(unique_id: "primeroprogram-primero"),
  name:                    'PC',
  description:             'Prevention Components',
  associated_record_types: [ 'case', 'tracing_request', 'incident', 'registry_record' ],
  core_resource:           true,
  # form_sections:         form_sections, # Can be updated later on as There are no forms for this Module yet. Sending an Empty Hash would cause an Error.
  field_map:               field_map,
  module_options:          module_options
)
