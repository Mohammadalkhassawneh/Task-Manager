class CreateProjectPermissions < ActiveRecord::Migration[7.2]
  def change
    create_table :project_permissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :permission_type

      t.timestamps
    end
  end
end
