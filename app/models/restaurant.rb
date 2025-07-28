class Restaurant < ApplicationRecord
  include AASM

  belongs_to :user

  validates :name, :description, :location, :cuisine_type, presence: true

  aasm column: :status do
    state :open, initial: true
    state :closed
    state :archived
  end
end
