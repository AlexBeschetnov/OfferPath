class DashboardController < ApplicationController
  def show
    applications = Current.user.job_applications

    @stats = JobSearchStats.new(applications)
    @next_steps = applications.with_next_step.limit(5)
    @stale = applications.stale.order(:status_changed_at).limit(5)
  end
end
