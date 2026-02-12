class AddRoleTypeAndStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role_type, :integer, default: 1
    add_column :users, :status, :integer, default: 1
  end
end
