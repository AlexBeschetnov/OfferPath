# Aggregated numbers for the dashboard, calculated over any job application scope.
class JobSearchStats
  RESPONSE_STATUSES = %w[interview offer].freeze

  def initialize(applications)
    @applications = applications
  end

  def total
    @total ||= @applications.count
  end

  def counts_by_status
    @counts_by_status ||= JobApplication::STATUSES.index_with(0).merge(@applications.group(:status).count)
  end

  def share(status)
    total.zero? ? 0 : (counts_by_status[status] * 100.0 / total).round
  end

  # Everything that has left the wishlist, i.e. was actually sent to an employer.
  def submitted
    total - counts_by_status["wishlist"]
  end

  # Applications that ever reached an interview, even if they were rejected later.
  def responded
    @responded ||= @applications
      .where(id: StatusChange.where(to_status: RESPONSE_STATUSES).select(:job_application_id))
      .count
  end

  def response_rate
    return 0 if submitted.zero?

    [(responded * 100.0 / submitted).round, 100].min
  end

  def offers
    counts_by_status["offer"]
  end

  def applied_this_week
    @applications.where(applied_on: Date.current.beginning_of_week..).count
  end
end
