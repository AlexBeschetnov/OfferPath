require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "signs in with valid credentials" do
    sign_in_as users(:alice)

    assert_redirected_to root_url
    assert cookies[:session_id].present?
  end

  test "rejects invalid password" do
    sign_in_as users(:alice), password: "wrong-password"

    assert_redirected_to new_session_path
    assert_equal "Invalid email or password", flash[:alert]
  end

  test "keeps passwords out of the logs" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

    assert_equal "[FILTERED]", filter.filter("password" => "password123")["password"]
    assert_equal "[FILTERED]", filter.filter("user" => { "password_confirmation" => "x" })["user"]["password_confirmation"]
  end

  test "signs out" do
    sign_in_as users(:alice)

    assert_difference -> { users(:alice).sessions.count }, -1 do
      delete session_path
    end
    assert_redirected_to new_session_path
  end
end
