class CreateTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :tokens do |t|
      t.text :value
      t.datetime :expired_at

      t.timestamps
    end
  end
end
