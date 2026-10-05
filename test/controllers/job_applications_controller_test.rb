require "test_helper"

class JobApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "redirects guests to sign in" do
    delete session_path
    get job_applications_path

    assert_redirected_to new_session_path
  end

  test "lists only own applications" do
    get job_applications_path

    assert_response :success
    assert_match "Acme", response.body
    assert_no_match "Umbrella", response.body
  end

  test "filters by query and status" do
    get job_applications_path(q: "glob")
    assert_match "Globex", response.body
    assert_no_match "Acme", response.body

    get job_applications_path(status: "wishlist")
    assert_match "Initech", response.body
    assert_no_match "Globex", response.body
  end

  test "renders the board" do
    get board_job_applications_path

    assert_response :success
    assert_select ".board__column", JobApplication::STATUSES.size
  end

  test "exports csv" do
    get job_applications_path(format: :csv)

    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match "Acme", response.body
    assert_no_match "Umbrella", response.body
  end

  test "shows an application with history" do
    get job_application_path(job_applications(:globex))

    assert_response :success
    assert_select ".timeline li", 2
  end

  test "does not expose someone else's application" do
    get job_application_path(job_applications(:umbrella))
    assert_response :not_found

    patch move_job_application_path(job_applications(:umbrella)), params: { status: "rejected" }
    assert_response :not_found
    assert job_applications(:umbrella).reload.applied?
  end

  test "creates an application" do
    assert_difference -> { users(:alice).job_applications.count }, 1 do
      post job_applications_path, params: {
        job_application: { company: "Hooli", position: "Rails Developer", status: "applied", salary_from: 120_000 }
      }
    end

    application = JobApplication.find_by!(company: "Hooli")
    assert_redirected_to job_application_path(application)
    assert_equal users(:alice), application.user
    assert_equal Date.current, application.applied_on
  end

  test "re-renders the form on invalid input" do
    assert_no_difference -> { JobApplication.count } do
      post job_applications_path, params: { job_application: { company: "", position: "" } }
    end

    assert_response :unprocessable_entity
    assert_select ".errors"
  end

  test "updates an application" do
    patch job_application_path(job_applications(:acme)), params: { job_application: { notes: "Call back on Friday" } }

    assert_redirected_to job_application_path(job_applications(:acme))
    assert_equal "Call back on Friday", job_applications(:acme).reload.notes
  end

  test "moves an application to the next status" do
    patch move_job_application_path(job_applications(:acme)), params: { status: "interview" }

    assert_redirected_to board_job_applications_path
    assert job_applications(:acme).reload.interview?
  end

  test "ignores an unknown status" do
    patch move_job_application_path(job_applications(:acme)), params: { status: "hired" }

    assert_redirected_to board_job_applications_path
    assert_equal "Unknown status", flash[:alert]
    assert job_applications(:acme).reload.applied?
  end

  test "destroys an application with its history" do
    assert_difference -> { StatusChange.count }, -2 do
      delete job_application_path(job_applications(:globex))
    end

    assert_redirected_to job_applications_path
    assert_not JobApplication.exists?(job_applications(:globex).id)
  end
end
