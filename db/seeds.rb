# Demo account: demo@example.com / password123
user = User.find_or_create_by!(email_address: "demo@example.com") do |u|
  u.password = "password123"
end

return if user.job_applications.exists?

[
  { company: "Stripe", position: "Junior Ruby Engineer", status: "interview", salary_from: 110_000, salary_to: 140_000,
    next_step: "Technical interview", next_step_on: 2.days.from_now.to_date },
  { company: "Shopify", position: "Backend Developer (Ruby)", status: "applied", salary_from: 120_000,
    applied_on: 20.days.ago.to_date, stale: true },
  { company: "GitHub", position: "Ruby on Rails Engineer", status: "applied", applied_on: 3.days.ago.to_date },
  { company: "Airbnb", position: "Software Engineer, Backend", status: "rejected", applied_on: 30.days.ago.to_date,
    notes: "Feedback: brush up on SQL and system design. Reapply in 6 months." },
  { company: "Gusto", position: "Rails Developer", status: "offer", salary_from: 125_000, salary_to: 145_000,
    next_step: "Reply to the offer", next_step_on: 1.day.from_now.to_date },
  { company: "Instacart", position: "Full-Stack Rails Engineer", status: "wishlist",
    posting_url: "https://example.com/jobs/42" },
  { company: "Basecamp", position: "Programmer, Ruby on Rails", status: "wishlist" }
].each do |attrs|
  stale = attrs.delete(:stale)
  application = user.job_applications.create!(attrs)
  application.update_columns(status_changed_at: 20.days.ago) if stale
end
