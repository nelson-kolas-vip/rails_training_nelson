module Api
  module V1
    class DestroyUserInteraction < ActiveInteraction::Base
      integer :id

      def execute
        user = User.find_by(id:)

        unless user
          errors.add(:base, 'User not found')
          return nil
        end

        user.destroy
        user
      end
    end
  end
end
