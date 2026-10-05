require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects guests to sign in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "shows stats, upcoming steps and stale applications" do
    sign_in_as users(:alice)

    get root_path

    assert_response :success
    assert_select ".stat__value", text: "50%"
    assert_match "Technical interview", response.body
    assert_match "Acme", response.body
    assert_no_match "Umbrella", response.body
  end
end
