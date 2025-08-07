class AddCurrentUserUrlToFeedbacks < ActiveRecord::Migration[8.0]
  def change
    add_column :feedbacks, :current_user_url, :string
  end
end
