require 'test_helper'
require 'webmock'

class SessionsControllerTest < ActionController::TestCase
  tests Devise::SessionsController
  include Devise::TestHelpers
  include WebMock::API

  setup do
    APP_CONFIG["nlm"]["enabled"] = true
    user = User.find_by email: "test@mitre.org"
    if user == nil
      User.create!(email: "test@mitre.org", password: "Password1", first_name: "test", last_name: "test", terms_and_conditions: "1")
    end
  end

  test "#Expects response status 302 when Username/Password and VSAC auth passes" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    stub_request(:post,'https://uts-ws.nlm.nih.gov/restful/isValidUMLSUser').with(:body =>{"password"=>"test", "user"=>"test", "licenseCode"=>"ReplaceThis"}).to_return( :body=>"<?xml version='1.0' encoding='UTF-8'?><Result>true</Result>")
    post :create, {user: {email: "test@mitre.org", password: "Password1"}, vsacuser: "test", vsacpassword: "test"}
    assert_equal 302, @response.status
  end

  test "#Expects response status 200 when Username/Password passes VSAC auth fails" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    stub_request(:post,'https://uts-ws.nlm.nih.gov/restful/isValidUMLSUser').with(:body =>{"password"=>"test", "user"=>"test", "licenseCode"=>"ReplaceThis"}).to_return( :body=>"<?xml version='1.0' encoding='UTF-8'?><Result>false</Result>")
    post :create, {user: {email: "test@mitre.org", password: "Password1"}, vsacuser: "test", vsacpassword: "test"}
    assert_equal 200, @response.status
  end

  test "#Expects response status 200 when Username/Password fails and VSAC auth passes" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    stub_request(:post,'https://uts-ws.nlm.nih.gov/restful/isValidUMLSUser').with(:body =>{"password"=>"test", "user"=>"test", "licenseCode"=>"ReplaceThis"}).to_return( :body=>"<?xml version='1.0' encoding='UTF-8'?><Result>true</Result>")
    post :create, {user: {email: "test@mitre.org", password: "Password"}, vsacuser: "test", vsacpassword: "test"}
    assert_equal 200, @response.status
  end

  test "#Expects response status 200 when Username/Password fails VSAC auth fails" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    stub_request(:post,'https://uts-ws.nlm.nih.gov/restful/isValidUMLSUser').with(:body =>{"password"=>"test", "user"=>"test", "licenseCode"=>"ReplaceThis"}).to_return( :body=>"<?xml version='1.0' encoding='UTF-8'?><Result>false</Result>")
    post :create, {user: {email: "test@mitre.org", password: "Password"}, vsacuser: "test", vsacpassword: "test"}
    assert_equal 200, @response.status
  end
end