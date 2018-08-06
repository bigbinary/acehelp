# frozen_string_literal: true

require "test_helper"

class ExamplesController < ApplicationController
  include LoadOrganization

  def index
    render json: { message: "Successful response" }
  end
end


class ExamplesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = Organization.first
    Rails.application.routes.draw do
      get "example_index" => "examples#index"
    end
    @headers = { "api-key": @organization.api_key }
    @params = { url: "http://google.com" }
  end

  teardown do
    Rails.application.reload_routes!
  end

  def test_load_action_when_header_and_param_is_passed
    get "/example_index", params: @params, headers: @headers
    assert_response :success
  end

  def test_load_organization_when_header_is_missing
    get "/example_index", params: @params
    assert_response :success
  end

  def test_load_organization_when_wrong_api_key_is_passed
    headers = { "api-key": "fake_api_key" }

    get "/example_index", params: @params, headers: headers
    assert_response :unauthorized
  end
end
