class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :order_number, null: false
      t.string :customer_name, null: false
      t.jsonb :items, null: false, default: []
      t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0.0
      t.references :user, null: false, foreign_key: true
      t.references :restaurant, null: false, foreign_key: true
      t.references :table, null: false, foreign_key: true

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_column :orders, :status, :integer, default: 0 # Adds the new status column
  end
end
