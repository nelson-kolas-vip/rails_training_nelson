class Menu < ApplicationRecord
  belongs_to :restaurant

  validates :item_name, :description, :price, :category, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :available, inclusion: { in: [true, false] }
  enum :veg_status, { veg: 0, non_veg: 1 }
end
