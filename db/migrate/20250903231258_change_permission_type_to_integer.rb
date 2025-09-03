class ChangePermissionTypeToInteger < ActiveRecord::Migration[7.2]
  def change
    change_column :project_permissions, :permission_type, :integer, using: "CASE permission_type WHEN 'read' THEN 0 WHEN 'write' THEN 1 ELSE 0 END"
  end
end
