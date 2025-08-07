class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.integer :rating
      t.text :comment
      t.string :customer_name
      t.references :restaurant, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
