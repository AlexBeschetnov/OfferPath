require "csv"

class JobApplication < ApplicationRecord
  STATUSES = %w[wishlist applied interview offer rejected].freeze
  PIPELINE = %w[wishlist applied interview offer].freeze
  STALE_AFTER = 14.days
  AWAITING_RESPONSE = %w[applied interview].freeze
  CSV_COLUMNS = %i[company position status salary_from salary_to applied_on next_step next_step_on posting_url notes].freeze

  belongs_to :user
  has_many :status_changes, dependent: :delete_all

  enum :status, STATUSES.index_by(&:itself), default: "wishlist", validate: true

  normalizes :company, :position, with: ->(value) { value.squish }

  validates :company, :position, presence: true, length: { maximum: 120 }
  validates :posting_url, format: { with: %r{\Ahttps?://\S+\z}i }, allow_blank: true
  validates :salary_from, :salary_to, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :salary_range_is_valid

  before_save :stamp_status_change, if: -> { new_record? || will_save_change_to_status? }
  before_save :set_applied_on, if: -> { applied_on.nil? && !wishlist? }
  after_save :record_status_change, if: -> { previously_new_record? || saved_change_to_status? }

  scope :recent, -> { order(updated_at: :desc) }
  scope :pending, -> { where(status: %w[wishlist applied interview]) }
  scope :stale, -> { where(status: AWAITING_RESPONSE, status_changed_at: ...STALE_AFTER.ago) }
  scope :with_next_step, -> { not_rejected.where.not(next_step_on: nil).order(:next_step_on) }
  scope :search, ->(query) {
    if query.present?
      where("company LIKE :pattern ESCAPE '\\' OR position LIKE :pattern ESCAPE '\\'",
            pattern: "%#{sanitize_sql_like(query.strip)}%")
    end
  }

  def self.human_status(status)
    I18n.t("job_application.statuses.#{status}")
  end

  def self.to_csv(records)
    CSV.generate(headers: true) do |csv|
      csv << CSV_COLUMNS.map { |column| human_attribute_name(column) }
      records.each do |record|
        csv << CSV_COLUMNS.map { |column| column == :status ? human_status(record.status) : record.public_send(column) }
      end
    end
  end

  def next_status
    index = PIPELINE.index(status)
    PIPELINE[index + 1] if index
  end

  def closed?
    rejected? || offer?
  end

  def overdue?
    next_step_on.present? && next_step_on < Date.current
  end

  private

  def salary_range_is_valid
    return if salary_from.blank? || salary_to.blank?

    errors.add(:salary_to, :less_than_salary_from) if salary_to < salary_from
  end

  def stamp_status_change
    self.status_changed_at = Time.current
  end

  def set_applied_on
    self.applied_on = Date.current
  end

  def record_status_change
    status_changes.create!(
      from_status: previously_new_record? ? nil : status_before_last_save,
      to_status: status
    )
  end
end
