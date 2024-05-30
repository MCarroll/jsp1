require "test_helper"

class ApplicationClientTest < ActiveSupport::TestCase
  setup do
    @client = ApplicationClient.new(token: "test")
  end

  test "authorization header" do
    stub_request(:get, "https://example.org/").with(headers: {"Authorization" => "Bearer test"})
    assert_nothing_raised do
      @client.send(:get, "/")
    end
  end

  test "get" do
    stub_request(:get, "https://example.org/test")
    assert_nothing_raised do
      @client.send(:get, "/test")
    end
  end

  test "get with query params" do
    stub_request(:get, "https://example.org/test").with(query: {"foo" => "bar"})
    assert_nothing_raised do
      @client.send(:get, "/test", query: {foo: "bar"})
    end
  end

  test "get with query params as a string" do
    stub_request(:get, "https://example.org/test").with(query: {"foo" => "bar"})
    assert_nothing_raised do
      @client.send(:get, "/test", query: "foo=bar")
    end
  end

  test "override BASE_URI by passing in full url" do
    stub_request(:get, "https://other.org/test")
    assert_nothing_raised do
      @client.send(:get, "https://other.org/test")
    end
  end

  test "post" do
    stub_request(:post, "https://example.org/test").with(body: {"foo" => {"bar" => "baz"}}.to_json)
    assert_nothing_raised do
      @client.send(:post, "/test", body: {foo: {bar: "baz"}})
    end
  end

  test "post with string body" do
    stub_request(:post, "https://example.org/test").with(body: "foo")
    assert_nothing_raised do
      @client.send(:post, "/test", body: "foo")
    end
  end

  test "post with custom content-type" do
    headers = {"Content-Type" => "application/x-www-form-urlencoded"}
    stub_request(:post, "https://example.org/test").with(body: {"foo" => "bar"}.to_json, headers: headers)
    assert_nothing_raised do
      @client.send(:post, "/test", body: {foo: "bar"}, headers: headers)
    end
  end

  test "multipart form data with file_fixture" do
    file = file_fixture("avatar.jpg")
    form_data = {
      "field1" => "value1",
      "file" => File.open(file)
    }

    stub_request(:post, "https://example.org/upload").to_return(status: 200)
    assert_nothing_raised do
      @client.send(:post, "/upload", form_data: form_data)
    end
  end

  test "patch" do
    stub_request(:patch, "https://example.org/test").with(body: {"foo" => "bar"}.to_json)
    assert_nothing_raised do
      @client.send(:patch, "/test", body: {foo: "bar"})
    end
  end

  test "multipart form data with file_fixture and patch" do
    file = file_fixture("avatar.jpg")

    form_data = {
      "field1" => "value1",
      "file" => File.open(file)
    }

    stub_request(:patch, "https://example.org/update").to_return(status: 200)

    assert_nothing_raised do
      @client.send(:patch, "/update", form_data: form_data)
    end
  end

  test "put" do
    stub_request(:put, "https://example.org/test").with(body: {"foo" => "bar"}.to_json)
    assert_nothing_raised do
      @client.send(:put, "/test", body: {foo: "bar"})
    end
  end

  test "multipart form data with file_fixture and put" do
    file = file_fixture("avatar.jpg")

    form_data = {
      "field1" => "value1",
      "file" => File.open(file)
    }

    stub_request(:put, "https://example.org/update").to_return(status: 200)

    assert_nothing_raised do
      @client.send(:put, "/update", form_data: form_data)
    end
  end

  test "delete" do
    stub_request(:delete, "https://example.org/test")
    assert_nothing_raised do
      @client.send(:delete, "/test")
    end
  end

  test "response object parses json" do
    stub_request(:get, "https://example.org/test").to_return(body: {"foo" => "bar"}.to_json, headers: {content_type: "application/json"})
    result = @client.send(:get, "/test")
    assert_equal "200", result.code
    assert_equal "application/json", result.content_type
    assert_equal "bar", result.foo
  end

  test "response object parses xml" do
    stub_request(:get, "https://example.org/test").to_return(body: {"foo" => "bar"}.to_xml, headers: {content_type: "application/xml"})
    result = @client.send(:get, "/test")
    assert_equal "200", result.code
    assert_equal "application/xml", result.content_type
    assert_equal "bar", result.xpath("//foo").children.first.to_s
  end

  test "unauthorized" do
    stub_request(:get, "https://example.org/test").to_return(status: 401)
    assert_raises ApplicationClient::Unauthorized do
      @client.send(:get, "/test")
    end
  end

  test "forbidden" do
    stub_request(:get, "https://example.org/test").to_return(status: 403)
    assert_raises ApplicationClient::Forbidden do
      @client.send(:get, "/test")
    end
  end

  test "not found" do
    stub_request(:get, "https://example.org/test").to_return(status: 404)
    assert_raises ApplicationClient::NotFound do
      @client.send(:get, "/test")
    end
  end

  test "rate limit" do
    stub_request(:get, "https://example.org/test").to_return(status: 429)
    assert_raises ApplicationClient::RateLimit do
      @client.send(:get, "/test")
    end
  end

  test "internal error" do
    stub_request(:get, "https://example.org/test").to_return(status: 500)
    assert_raises ApplicationClient::InternalError do
      @client.send(:get, "/test")
    end
  end

  test "other error" do
    stub_request(:get, "https://example.org/test").to_return(status: 418)
    assert_raises ApplicationClient::Error do
      @client.send(:get, "/test")
    end
  end

  test "parses link header" do
    stub_request(:get, "https://example.org/pages").to_return(headers: {"Link" => "<https://example.org/pages?page=2>; rel=\"next\", <https://example.org/pages?page=1>; rel=\"prev\""})
    response = @client.send(:get, "/pages")
    assert_equal "https://example.org/pages?page=2", response.link_header[:next]
    assert_equal "https://example.org/pages?page=1", response.link_header[:prev]
  end

  test "handles missing link header" do
    stub_request(:get, "https://example.org/pages")
    response = @client.send(:get, "/pages")
    assert_empty(response.link_header)
  end

  class CustomClientTest < ActiveSupport::TestCase
    class TestApiClient < ApplicationClient
      BASE_URI = "https://test.example.org"

      def root
        get "/"
      end

      def content_type
        "application/xml"
      end

      def all_pages
        with_pagination("/pages", query: {per_page: 100}) do |response|
          response.link_header[:next]
        end
      end

      def all_projects
        with_pagination("/projects", query: {per_page: 100}) do |response|
          next_page = response.parsed_body.pagination.next_page
          {page: next_page} if next_page
        end
      end
    end

    test "with_pagination and url" do
      stub_request(:get, "https://test.example.org/pages?per_page=100").to_return(headers: {"Link" => "<https://test.example.org/pages?page=2>; rel=\"next\""})
      stub_request(:get, "https://test.example.org/pages?per_page=100&page=2")
      assert_nothing_raised do
        TestApiClient.new(token: "test").all_pages
      end
    end

    test "with_pagination with query hash" do
      stub_request(:get, "https://test.example.org/projects?per_page=100").to_return(body: {pagination: {next_page: 2}}.to_json, headers: {content_type: "application/json"})
      stub_request(:get, "https://test.example.org/projects?per_page=100&page=2").to_return(body: {pagination: {prev_page: 1}}.to_json, headers: {content_type: "application/json"})
      assert_nothing_raised do
        TestApiClient.new(token: "test").all_projects
      end
    end

    test "get" do
      stub_request(:get, "https://test.example.org/")
      assert_nothing_raised do
        TestApiClient.new(token: "test").root
      end
    end

    test "content type" do
      stub_request(:get, "https://test.example.org/").with(headers: {"Accept" => "application/xml"})
      assert_nothing_raised do
        TestApiClient.new(token: "test").root
      end
    end

    test "other error" do
      stub_request(:get, "https://test.example.org/").to_return(status: 418)
      assert_raises TestApiClient::Error do
        TestApiClient.new(token: "test").root
      end
    end
  end
end
