module Api
  module V1
    class CreateUserInteraction < ActiveInteraction::Base
      string :first_name, :last_name, :email, :phone_number, :password, :password_confirmation
      integer :age
      date :date_of_birth
      validates :password, confirmation: true

      def execute
        if User.exists?(email: email)
          errors.add(:email, 'has already been taken')
          return
        end

        User.create!(
          first_name: first_name,
          last_name: last_name,
          email: email,
          phone_number: phone_number,
          password: password,
          password_confirmation: password_confirmation,
          age: age,
          date_of_birth: date_of_birth
        )
      rescue ActiveRecord::RecordInvalid => e
        errors.merge!(e.record.errors)
        nil
      end
    end
  end
end
