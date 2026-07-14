class Availability < ApplicationRecord
  DAYS_OF_WEEK = {
    0 => 'Sunday',
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday'
  }.freeze

  belongs_to :tutor_profile, optional: false

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :start_time, presence: true
  validates :end_time,   presence: true
  validate  :end_after_start
  validate  :no_overlap_with_existing

  scope :for_day, ->(n) { where(day_of_week: n) }

  def day_name
    DAYS_OF_WEEK[day_of_week] || "Day #{day_of_week}"
  end

  def length_minutes
    (end_time - start_time) / 60
  end

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?

    return unless end_time <= start_time

    errors.add(:end_time, 'must be after start_time')
  end

  def no_overlap_with_existing
    return if start_time.blank? || end_time.blank? || day_of_week.blank? || tutor_profile_id.blank?

    conflicting = Availability
                  .where(tutor_profile_id: tutor_profile_id, day_of_week: day_of_week)
                  .where.not(id: id)
                  .where('start_time < ? AND ? < end_time', end_time, start_time)

    return if conflicting.empty?

    errors.add(:base, 'overlaps with an existing availability window for this day')
  end
end
