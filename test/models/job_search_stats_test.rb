require "test_helper"

class JobSearchStatsTest < ActiveSupport::TestCase
  setup do
    @stats = JobSearchStats.new(users(:alice).job_applications)
  end

  test "counts applications by status including empty ones" do
    assert_equal(
      { "wishlist" => 1, "applied" => 1, "interview" => 1, "offer" => 0, "rejected" => 0 },
      @stats.counts_by_status
    )
  end

  test "submitted excludes wishlist" do
    assert_equal 3, @stats.total
    assert_equal 2, @stats.submitted
  end

  test "response rate counts applications that reached an interview" do
    assert_equal 1, @stats.responded
    assert_equal 50, @stats.response_rate
  end

  test "response rate stays at the interview even after a rejection" do
    job_applications(:globex).update!(status: "rejected")

    assert_equal 50, JobSearchStats.new(users(:alice).job_applications).response_rate
  end

  test "handles a user without applications" do
    stats = JobSearchStats.new(JobApplication.none)

    assert_equal 0, stats.total
    assert_equal 0, stats.response_rate
    assert_equal 0, stats.share("applied")
  end
end
