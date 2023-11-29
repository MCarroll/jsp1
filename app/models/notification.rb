class Notification < ApplicationRecord
  include Noticed::Model

  belongs_to :account

  def self.mark_as_interacted!
    update(interacted_at: Time.current, updated_at: Time.current)
  end

  def mark_as_interacted!
    update(interacted_at: Time.current)
  end
end
