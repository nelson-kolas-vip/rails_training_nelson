class Changedefaultvalueofrole < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :role_type, 3
  end
end
