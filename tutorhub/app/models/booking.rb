# frozen_string_literal: true

# Booking is the join record between a student and a tutor for a specific
# calendar slot. It is the heart of the booking engine — every state change
# (confirm, cancel, complete) flows through the hand-rolled methods below.
#
# Concurrency strategy:
#   * INSERT race-safety is provided by the DB-level UNIQUE INDEX on
#     (tutor_id, booking_date, start_time). That index is the only authoritative
#     guarantee that two students cannot claim the same slot.
#   * UPDATE race-safety is provided by ActiveRecord optimistic locking via the
#     `lock_version` column. Two concurrent state transitions (e.g. tutor
#     confirms while student cancels) cannot both succeed — the loser raises
#     ActiveRecord::StaleObjectError.
#   * The application-layer `no_double_booking` validator is purely a UX
#     affordance so the user sees a clean error message instead of having to
#     retry after the DB rejects the INSERT.
class Booking < ApplicationRecord
  class InvalidTransitionError < StandardError; end

  self.locking_column = :lock_version

  belongs_to :student, class_name: 'User'
  belongs_to :tutor,   class_name: 'User'

  has_one :review, dependent: :destroy

  # `tutor_profile` is a convenience accessor exposed via delegation. Not every
  # tutor will have one (e.g. a user upgraded to tutor without completing
  # onboarding), so the delegation is tolerant of a nil profile.
  delegate :tutor_profile, to: :tutor, allow_nil: true
  delegate :hourly_rate, :subject, to: :tutor_profile, allow_nil: true

  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }

  validates :booking_date, presence: true
  validates :start_time,   presence: true
  validates :end_time,     presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  validate :end_after_start
  validate :student_is_student
  validate :tutor_is_tutor
  validate :not_self_booking
  validate :booking_date_not_in_past, on: :create
  validate :no_double_booking_application_layer

  # ── State machine (hand-rolled, no AASM gem) ────────────────────────────
  def confirm!
    raise InvalidTransitionError, 'Only pending bookings can be confirmed' unless pending?

    update!(status: :confirmed)
  end

  def cancel!
    raise InvalidTransitionError, 'Cannot cancel a completed booking' if completed?
    raise InvalidTransitionError, 'Booking is already cancelled' if cancelled?

    update!(status: :cancelled)
  end

  def complete!
    raise InvalidTransitionError, 'Only confirmed bookings can be completed' unless confirmed?

    update!(status: :completed)
  end

  def cancellable?
    !completed? && !cancelled?
  end

  def length_minutes
    return 0 unless end_time && start_time

    ((end_time - start_time) / 60).to_i
  end

  private

  def end_after_start
    return if end_time.blank? || start_time.blank?

    errors.add(:end_time, 'must be after start_time') if end_time <= start_time
  end

  def student_is_student
    return if student_id.blank?

    errors.add(:student_id, 'must reference a student') unless student&.student?
  end

  def tutor_is_tutor
    return if tutor_id.blank?

    errors.add(:tutor_id, 'must reference a tutor') unless tutor&.tutor?
  end

  def not_self_booking
    return if tutor_id.blank? || student_id.blank?

    errors.add(:base, 'cannot book yourself') if tutor_id == student_id
  end

  def booking_date_not_in_past
    return if booking_date.blank?

    errors.add(:booking_date, 'must be today or in the future') if booking_date < Date.current
  end

  # Application-layer uniqueness check for clean UX.
  # The DB UNIQUE INDEX is the *real* race-proof guarantee.
  def no_double_booking_application_layer
    return if tutor_id.blank? || booking_date.blank? || start_time.blank?

    conflict = Booking
               .where(tutor_id: tutor_id, booking_date: booking_date, start_time: start_time)
               .where.not(id: id)

    errors.add(:base, 'That slot is already booked') if conflict.exists?
  end
end
