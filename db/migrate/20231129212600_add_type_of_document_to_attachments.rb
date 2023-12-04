class AddTypeOfDocumentToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :attachments, :type_of_document, :string
  end
end
