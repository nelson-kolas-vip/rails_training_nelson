class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body
      t.boolean :published
      t.string :author

      t.timestamps
    end
  end
end
