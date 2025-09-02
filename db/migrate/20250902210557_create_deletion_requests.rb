class CreateDeletionRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :deletion_requests do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :reason
      t.integer :status

      t.timestamps
    end
  end
end
