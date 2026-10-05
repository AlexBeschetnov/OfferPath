module JobApplicationsHelper
  def status_badge(status)
    tag.span JobApplication.human_status(status), class: "badge badge--#{status}"
  end

  def status_options
    JobApplication::STATUSES.map { |status| [JobApplication.human_status(status), status] }
  end

  def salary_range(application)
    from, to = application.salary_from, application.salary_to
    usd = ->(amount) { number_to_currency(amount, precision: 0) }

    if from && to
      "#{usd.(from)} – #{usd.(to)}"
    elsif from
      "#{usd.(from)}+"
    elsif to
      "up to #{usd.(to)}"
    else
      "—"
    end
  end

  def short_date(date)
    date ? l(date, format: :short) : "—"
  end
end
