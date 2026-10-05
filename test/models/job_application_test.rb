require "test_helper"

class JobApplicationTest < ActiveSupport::TestCase
  setup do
    @user = users(:alice)
  end

  test "requires company and position" do
    application = @user.job_applications.new

    assert_not application.valid?
    assert application.errors.added?(:company, :blank)
    assert application.errors.added?(:position, :blank)
  end

  test "squishes company and position" do
    application = @user.job_applications.new(company: "  Hooli   Inc ", position: " Dev ")

    assert_equal "Hooli Inc", application.company
    assert_equal "Dev", application.position
  end

  test "rejects salary range where upper bound is lower" do
    application = @user.job_applications.new(company: "Hooli", position: "Dev", salary_from: 200_000, salary_to: 100_000)

    assert_not application.valid?
    assert application.errors.added?(:salary_to, :less_than_salary_from)
  end

  test "rejects non-http posting url" do
    application = @user.job_applications.new(company: "Hooli", position: "Dev", posting_url: "javascript:alert(1)")

    assert_not application.valid?
    assert application.errors.of_kind?(:posting_url, :invalid)
  end

  test "rejects unknown status" do
    application = @user.job_applications.new(company: "Hooli", position: "Dev", status: "hired")

    assert_not application.valid?
    assert application.errors.of_kind?(:status, :inclusion)
  end

  test "records history on create and on status change" do
    application = @user.job_applications.create!(company: "Hooli", position: "Dev")

    assert_equal [[nil, "wishlist"]], application.status_changes.order(:id).pluck(:from_status, :to_status)

    application.update!(status: "applied")
    application.update!(notes: "Notes do not create history")

    assert_equal [[nil, "wishlist"], %w[wishlist applied]], application.status_changes.order(:id).pluck(:from_status, :to_status)
  end

  test "sets applied_on once application leaves the wishlist" do
    application = job_applications(:initech)
    assert_nil application.applied_on

    application.update!(status: "applied")

    assert_equal Date.current, application.applied_on
  end

  test "stale scope returns applications without movement for two weeks" do
    stale = @user.job_applications.stale

    assert_includes stale, job_applications(:acme)
    assert_not_includes stale, job_applications(:globex)
  end

  test "stale scope includes interviews without movement for two weeks" do
    job_applications(:globex).update_columns(status_changed_at: 15.days.ago)

    assert_includes @user.job_applications.stale, job_applications(:globex)
  end

  test "stale scope ignores applications moved less than two weeks ago" do
    job_applications(:acme).update_columns(status_changed_at: 13.days.ago)

    assert_not_includes @user.job_applications.stale, job_applications(:acme)
  end

  test "stale scope ignores wishlist and closed applications" do
    job_applications(:initech).update_columns(status_changed_at: 30.days.ago)
    job_applications(:globex).update_columns(status: "offer", status_changed_at: 30.days.ago)

    stale = @user.job_applications.stale

    assert_not_includes stale, job_applications(:initech)
    assert_not_includes stale, job_applications(:globex)
  end

  test "search matches company and position" do
    assert_equal [job_applications(:globex)], @user.job_applications.search("glob").to_a
    assert_equal [job_applications(:acme)], @user.job_applications.search("junior").to_a
    assert_equal 3, @user.job_applications.search("").count
  end

  test "search escapes LIKE wildcards" do
    assert_empty @user.job_applications.search("%")
  end

  test "next_status follows the pipeline" do
    assert_equal "applied", job_applications(:initech).next_status
    assert_equal "offer", job_applications(:globex).next_status
    assert_nil JobApplication.new(status: "offer").next_status
    assert_nil JobApplication.new(status: "rejected").next_status
  end

  test "exports csv with human readable headers and statuses" do
    csv = JobApplication.to_csv([job_applications(:acme)])

    assert csv.start_with?("Company,Position,Status")
    assert_includes csv, "Acme,Junior Rails Developer,Applied"
  end
end
