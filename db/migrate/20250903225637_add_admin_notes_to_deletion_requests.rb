class AddAdminNotesToDeletionRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :deletion_requests, :admin_notes, :text
  end
end
