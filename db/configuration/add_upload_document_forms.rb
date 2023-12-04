# frozen_string_literal: true

ActiveJob::Base.queue_adapter = :async

puts "\nCreating Upload Document Form 1 !!!!"

other_documents_fields_1 = [
  Field.new({
    "name" => "other_documents_1",
    "type" => "document_upload_box",
    "display_name_en" => "Other Document 1",
    "help_text_en" => "Only PDF, TXT, DOC, DOCX, XLS, XLSX, CSV, JPG, JPEG, PNG files permitted"
  })
]

FormSection.create_or_update!({
  unique_id: "other_upload_document_1",
  parent_form: "case",
  visible: true,
  fields: other_documents_fields_1,
  editable: false,
  name_en: "Other Upload Documents 1",
  description_en: "Other Upload Documents 1",
  form_group_id: "other_upload_documents_1",
  module_ids: ['primeromodule-cp'], # CP Module
  display_help_text_view: true
})

# ------------------------------------------------------------------------------------------------------

puts "\nCreating Upload Document Form 2 !!!!"

other_documents_fields_2 = [
  Field.new({
    "name" => "other_documents_2",
    "type" => "document_upload_box",
    "display_name_en" => "Other Document 2",
    "help_text_en" => "Only PDF, TXT, DOC, DOCX, XLS, XLSX, CSV, JPG, JPEG, PNG files permitted"
  })
]

FormSection.create_or_update!({
  unique_id: "other_upload_document_2",
  parent_form: "case",
  visible: true,
  fields: other_documents_fields_2,
  editable: false,
  name_en: "Other Upload Documents 2",
  description_en: "Other Upload Documents 2",
  form_group_id: "other_upload_documents_2",
  module_ids: ['primeromodule-cp'], # CP Module
  display_help_text_view: true
})

# ------------------------------------------------------------------------------------------------------

puts "\nCreating Upload Document Form 3 !!!!"

other_documents_fields_3 = [
  Field.new({
    "name" => "other_documents_3",
    "type" => "document_upload_box",
    "display_name_en" => "Other Document 3",
    "help_text_en" => "Only PDF, TXT, DOC, DOCX, XLS, XLSX, CSV, JPG, JPEG, PNG files permitted"
  })
]

# display_conditions: { disabled: true },

FormSection.create_or_update!({
  unique_id: "other_upload_document_3",
  parent_form: "case",
  visible: true,
  fields: other_documents_fields_3,
  editable: false,
  name_en: "Other Upload Documents 3",
  description_en: "Other Upload Documents 3",
  form_group_id: "other_upload_documents_3",
  module_ids: ['primeromodule-cp'], # CP Module
  display_help_text_view: true
})

# ------------------------------------------------------------------------------------------------------

puts "\nCreating Case Form LookUp !!!!"

Lookup.create_or_update!(
  :unique_id => "lookup-form-group-cp-case",
  :name_en => "Form Groups - CP Case",
  :lookup_values_en => [
    { id: 'other_upload_documents_1', display_text: "Other Upload Documents 1" },
    { id: 'other_upload_documents_2', display_text: "Other Upload Documents 2" },
    { id: 'other_upload_documents_3', display_text: "Other Upload Documents 3" },
  ].map(&:with_indifferent_access)
)

# ------------------------------------------------------------------------------------------------------
