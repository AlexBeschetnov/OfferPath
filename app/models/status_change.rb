class StatusChange < ApplicationRecord
  belongs_to :job_application

  validates :to_status, inclusion: { in: JobApplication::STATUSES }
end
