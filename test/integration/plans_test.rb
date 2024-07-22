require "test_helper"

class Jumpstart::PlansTest < ActionDispatch::IntegrationTest
  fixtures :plans

  setup do
    # Two expects handle multiple calls, if Braintree & PayPal are both enabled for example
    mock_client_token = Minitest::Mock.new
    mock_client_token.expect :generate, "mock_client_token"
    mock_client_token.expect :generate, "mock_client_token"

    mock_gateway = Minitest::Mock.new
    mock_gateway.expect :client_token, mock_client_token
    mock_gateway.expect :client_token, mock_client_token
    Pay.braintree_gateway = mock_gateway
  end

  test "redirects when there are no plans" do
    Plan.delete_all
    get "/pricing"
    assert_redirected_to root_url
  end

  test "view pricing page when there are plans" do
    get "/pricing"

    Plan.visible.find_each do |plan|
      assert_includes response.body, plan.name
    end
  end

  test "enterprise plan shows up" do
    get "/pricing"

    assert_select "a[href=?]", "mailto:user@example.com"
    assert_select "a", text: I18n.t("subscriptions.plan.contact_us")
    assert_select "span", text: I18n.t("subscriptions.plan.contact_us_price")
  end

  if Jumpstart.config.payments_enabled?
    test "can view subscribe page for a plan" do
      sign_in users(:one)
      plan = plans(:personal)

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(body: {id: "cus_1234", object: "customer"}.to_json)
      stub_request(:post, "https://api.stripe.com/v1/checkout/sessions").to_return(body: {id: "cs_test_1234", object: "checkout.session", client_secret: "example"}.to_json)

      get new_subscription_path(plan: plan)
      assert_nil flash.alert
      assert_response :success
    end

    test "can view subscribe page for a account plan" do
      account = accounts(:company)
      plan = plans(:personal)

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(body: {id: "cus_1234", object: "customer"}.to_json)
      stub_request(:post, "https://api.stripe.com/v1/checkout/sessions").to_return(body: {id: "cs_test_1234", object: "checkout.session", client_secret: "example"}.to_json)

      sign_in account.owner
      switch_account(account)
      get new_subscription_path(plan: plan)
      assert_nil flash.alert
      assert_response :success
    end
  end
end
