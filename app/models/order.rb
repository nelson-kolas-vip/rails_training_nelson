class Order < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant
  belongs_to :table

  validates :items, presence: true
  validates :total_price, presence: true
  validates :customer_name, presence: true
  validates :order_number, presence: true, uniqueness: true

  before_validation :generate_order_number, on: :create
  before_save :compute_total_price

  private

  def generate_order_number
    self.order_number ||= "ORD#{Time.current.strftime('%Y%m%d%H%M%S')}#{rand(1000)}"
  end

  def compute_total_price
    self.total_price = items.sum { |item| item["total_item_price"].to_f }
  end
end
