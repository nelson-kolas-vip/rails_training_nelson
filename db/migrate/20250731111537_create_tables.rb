class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables do |t|
      t.integer :table_number
      t.integer :seating_capacity
      t.integer :status, default: 0
      t.references :restaurant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
