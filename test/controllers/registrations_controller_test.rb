require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "creates an account and signs in" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: {
        user: { email_address: " New@Example.com ", password: "secret123", password_confirmation: "secret123" }
      }
    end

    assert_redirected_to root_path
    assert User.exists?(email_address: "new@example.com")
    assert cookies[:session_id].present?
  end

  test "rejects a short password" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: { email_address: "new@example.com", password: "123", password_confirmation: "123" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects a taken email" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: { email_address: "alice@example.com", password: "secret123", password_confirmation: "secret123" }
      }
    end

    assert_response :unprocessable_entity
  end
end
