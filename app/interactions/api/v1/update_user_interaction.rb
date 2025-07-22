module Api
  module V1
    class UpdateUserInteraction < ActiveInteraction::Base
      integer :id
      string :first_name, :last_name, :email, :phone_number, :password, :password_confirmation, :date_of_birth, default: nil
      integer :age, default: nil

      validates :password, confirmation: true, allow_nil: true

      def execute
        user = User.find_by(id: id)

        unless user
          errors.add(:base, 'User not found')
          return
        end

        update_attrs = inputs.except(:id).compact_blank

        if user.update(update_attrs)
          user
        else
          errors.merge!(user.errors)
          nil
        end
      end
    end
  end
end
