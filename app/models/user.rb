class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :avatar
  has_many :restaurants, dependent: :destroy

  enum :role_type, { admin: 1, staff: 2, customer: 3 }
  enum :status, { active: 1, inactive: 2 }
  def self.role_type_to_string(value)
    role_types.key(value)
  end
end
