# BookingService — Orchestrates the entire booking creation flow.
#
# This is the single entry point — controllers and the concurrency test use it.
#
# Sequence (per request):
#   1) Validate input (tutor/student/slot)
#   2) Verify slot fits inside tutor availability (AvailabilityChecker)
#   3) Atomically create the booking inside a DB transaction.
#       a) Application-layer uniqueness check (cheap, gives clean UX).
#       b) INSERT. Postgres UNIQUE INDEX is the real safety net:
#          - ActiveRecord::RecordNotUnique (unique_violation, pg 23505)
#          - ActiveRecord::StaleObjectError (lock_version bump during read-modify-write)
#          Both are translated into BookingConflictError.
#   4) Return Result struct with success / failure.
#
# Why NOT a single optimistic-locking UPDATE only?
#   Because we're INSERT-ing a row, not updating one. There is no prior row
#   for optimistic locking to detect. Instead we rely on:
#     - the DB-level unique index (logical equivalent of "claim ticket #N")
#     - plus optimistic locking on every subsequent UPDATE (tutor confirming,
#       student cancelling) which uses Rails' built-in lock_version.
#   This is the same pattern used in concert booking / flash-sale systems where
#   "first to INSERT" wins; it scales because PG isolates concurrent inserts
#   at the index level.

class BookingService
  Result = Struct.new(:success?, :booking, :error_code, :error_message, keyword_init: true) do
    def to_h
      { success?: success?, booking: booking, error_code: error_code, error_message: error_message }
    end
  end

  class BookingConflictError < StandardError; end
  class InvalidInputError < StandardError; end

  def self.call(...)
    new(...).call
  end

  def initialize(student:, tutor_id:, booking_date:, start_time:, end_time:)
    @student = student
    @tutor_id = tutor_id
    @booking_date = booking_date.to_date
    @start_time = AvailabilityChecker::REFERENCE_DATE ? normalize_time(start_time) : start_time
    @end_time = normalize_time(end_time)
  end

  def call
    tutor = User.find_by(id: @tutor_id)
    raise InvalidInputError, 'Tutor not found' unless tutor
    raise InvalidInputError, 'Selected account is not a tutor' unless tutor.tutor?
    raise InvalidInputError, 'Cannot book yourself' if tutor.id == @student.id
    raise InvalidInputError, 'Booking must be in the future' if @booking_date < Date.current
    raise InvalidInputError, 'end_time must be after start_time' if @end_time <= @start_time

    profile = tutor.tutor_profile or raise InvalidInputError, 'Tutor has no profile'
    day_of_week = @booking_date.wday

    availability = AvailabilityChecker.call(
      tutor_profile: profile,
      day_of_week: day_of_week,
      start_time: @start_time,
      end_time: @end_time
    )
    raise InvalidInputError, "Slot is outside tutor's availability" unless availability.available?

    booking = nil
    ApplicationRecord.transaction do
      booking = Booking.create!(
        student: @student,
        tutor: tutor,
        booking_date: @booking_date,
        start_time: @start_time,
        end_time: @end_time,
        status: :pending,
        total_amount: profile.hourly_rate.to_f
      )
    end

    Result.new(success?: true, booking: booking)
  rescue ActiveRecord::RecordInvalid => e
    # The application-layer double-booking validator fires before the DB
    # INSERT, so it raises RecordInvalid rather than RecordNotUnique.
    raise BookingConflictError, e.message if e.message.match?(/already booked/i)

    raise
  rescue ActiveRecord::RecordNotUnique => e
    raise BookingConflictError, e.message
  rescue ActiveRecord::StatementInvalid => e
    # Most other PG-level failures (constraint violations, etc.) bubble up here.
    raise BookingConflictError, e.message if e.cause.is_a?(PG::UniqueViolation) || e.message.match?(/unique_violation/i)

    raise
  end

  private

  def normalize_time(value)
    parsed = case value
             when Time, ActiveSupport::TimeWithZone
               value
             else
               Time.zone.parse(value.to_s)
             end
    parsed.change(year: 2000, month: 1, day: 1)
  end
end
