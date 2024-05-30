require "test_helper"

class Jumpstart::HerokuTest < ActiveSupport::TestCase
  def test_valid_app_json_syntax
    assert_nothing_raised do
      JSON.parse(File.read("app.json"))
    end
  end
end
