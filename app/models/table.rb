class Table < ApplicationRecord
  belongs_to :restaurant

  enum :status, { available: 0, occupied: 1, reserved: 2 }
  validates :table_number, presence: true, numericality: { only_integer: true }
  validates :seating_capacity, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 9 }
  validates :status, presence: true, inclusion: { in: %w[available occupied reserved] }
end
