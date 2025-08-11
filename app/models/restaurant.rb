class Restaurant < ApplicationRecord
  include AASM

  belongs_to :user
  has_many :tables, dependent: :destroy
  has_many :reservations
  has_many :feedbacks
  has_many :orders, dependent: :destroy

  validates :name, :description, :location, :cuisine_type, presence: true
  has_many :menus, dependent: :destroy
  aasm column: :status do
    state :open, initial: true
    state :closed
    state :archived
  end
end
