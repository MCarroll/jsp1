require "test_helper"

class ActionText::EmbedTest < ActiveSupport::TestCase
  test "renders name with ActionText to_plain_text" do
    embed = action_text_embeds(:one)
    assert_equal "[#{embed.url}]", embed.attachable_plain_text_representation
  end
end
