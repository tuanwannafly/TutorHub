# frozen_string_literal: true

module Api
  class BookingsController < BaseController
    before_action :require_api_login!

    rescue_from BookingService::BookingConflictError do |_e|
      render_error(:conflict, 'That slot was just taken — please pick another time.')
    end

    rescue_from BookingService::InvalidInputError do |e|
      render_error(:unprocessable_entity, e.message)
    end

    rescue_from Booking::InvalidTransitionError do |e|
      render_error(:unprocessable_entity, e.message)
    end

    def index
      bookings =
        if current_user.tutor?
          Booking.where(tutor_id: current_user.id).order(booking_date: :desc, start_time: :asc)
        else
          Booking.where(student_id: current_user.id).order(booking_date: :desc, start_time: :asc)
        end

      render_ok(bookings.map { |b| Api::Presenters.booking(b) })
    end

    def show
      b = Booking.find(params[:id])
      unless b.student_id == current_user.id || b.tutor_id == current_user.id
        return render_error(:forbidden, 'You are not a participant in that booking.')
      end

      render_ok(Api::Presenters.booking(b))
    end

    def create
      result = BookingService.call(
        student: current_user,
        tutor_id: params[:tutor_id],
        booking_date: params[:booking_date],
        start_time: parse_time(params[:start_time]),
        end_time: parse_time(params[:end_time])
      )

      if result.success?
        render_ok(Api::Presenters.booking(result.booking), status: :created)
      else
        render_error(:unprocessable_entity, result.error_message || 'Could not create booking.')
      end
    end

    def confirm
      b = Booking.find(params[:id])
      authorize_tutor!(b)
      b.confirm!
      render_ok(Api::Presenters.booking(b))
    end

    def cancel
      b = Booking.find(params[:id])
      authorize_participant!(b)
      b.cancel!
      render_ok(Api::Presenters.booking(b))
    end

    def complete
      b = Booking.find(params[:id])
      authorize_tutor!(b)
      b.complete!
      render_ok(Api::Presenters.booking(b))
    end

    private

    def authorize_tutor!(b)
      return if b.tutor_id == current_user.id

      render_error(:forbidden, 'Only the assigned tutor can perform that action.')
    end

    def authorize_participant!(b)
      return if b.student_id == current_user.id || b.tutor_id == current_user.id

      render_error(:forbidden, 'You are not a participant in that booking.')
    end

    # The React frontend sends "HH:MM" (no seconds). Rails `time` columns
    # expect a Time/DateTime/String parseable by Time.parse, so we normalize
    # to a Time object here. Falls back to the raw value to keep the
    # service's tolerance for already-coerced inputs.
    def parse_time(value)
      return value if value.is_a?(Time) || value.is_a?(DateTime)
      return nil if value.blank?

      Time.parse(value.to_s)
    rescue ArgumentError
      value
    end
  end
end
