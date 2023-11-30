module User::Mentions
  # Allows a user to be mentioned in ActionText fields

  extend ActiveSupport::Concern

  included do
    include ActionText::Attachable
  end

  # Display name when ActionText renders a user mention in plain text
  def attachable_plain_text_representation(caption = nil)
    caption || name
  end
end
