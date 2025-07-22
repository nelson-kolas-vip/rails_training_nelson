class Token < ApplicationRecord
  before_create :generate_secure_token, :set_expiration

  private

  def generate_secure_token
    self.value = SecureRandom.hex(32)
  end

  def set_expiration
    self.expired_at = 24.hours.from_now
  end
end
