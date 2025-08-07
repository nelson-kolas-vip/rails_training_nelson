class Feedback < ApplicationRecord
  belongs_to :restaurant, optional: true
  belongs_to :user

  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 500 }
  validates :customer_name, presence: true
  validates :user_id, presence: true
end
