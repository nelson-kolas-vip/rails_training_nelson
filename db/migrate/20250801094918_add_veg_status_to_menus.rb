class AddVegStatusToMenus < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :veg_status, :integer, default: 0, null: false
  end
end
