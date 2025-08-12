# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def change
    # Remove the old password_digest column used by has_secure_password
    remove_column :users, :password_digest, :string

    change_table :users do |t|
      ## Devise required fields
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
    end

    # Indexes
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true
  end
end
