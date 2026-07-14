# PORO service object.
#
# Decides whether a student's requested slot (day_of_week, start_time, end_time)
# falls inside one of the tutor's published availability windows.
#
# Important: this is *just one* guard. The race-proof guarantee comes from
# BookingsService + a DB unique index on (tutor_id, booking_date, start_time).
class AvailabilityChecker
  Result = Struct.new(:available?, :reason, keyword_init: true) do
    def to_h
      { available?: available?, reason: reason }
    end
  end

  REFERENCE_DATE = Date.new(2000, 1, 1)

  def self.call(...)
    new(...).call
  end

  def initialize(tutor_profile:, day_of_week:, start_time:, end_time:)
    @tutor_profile = tutor_profile
    @day_of_week   = day_of_week
    @start_time    = normalize(start_time)
    @end_time      = normalize(end_time)
  end

  def call
    windows = @tutor_profile.availabilities.where(day_of_week: @day_of_week)
    fitting = windows.select { |w| fits?(w) }

    return Result.new(available?: false, reason: :no_matching_window) if fitting.empty?

    Result.new(available?: true, reason: :ok)
  end

  private

  def normalize(value)
    parsed = case value
             when Time, ActiveSupport::TimeWithZone
               value
             else
               Time.zone.parse(value.to_s)
             end
    parsed.change(year: REFERENCE_DATE.year, month: REFERENCE_DATE.month, day: REFERENCE_DATE.day)
  end

  # A requested slot fits inside an availability window when the window covers
  # the requested time range AND the window is at least as long as the request.
  def fits?(window)
    window_start = normalize(window.start_time)
    window_end   = normalize(window.end_time)
    window_duration = (window_end - window_start) / 60
    requested_duration = (@end_time - @start_time) / 60

    window_start <= @start_time &&
      window_end >= @end_time &&
      window_duration >= requested_duration
  end
end
