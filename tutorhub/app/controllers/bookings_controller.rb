# frozen_string_literal: true

# BookingsController — Thin HTTP wrapper around BookingService.
#
# All non-trivial logic (validation, availability checks, concurrency) lives
# in BookingService. The controller's job is to:
#   * authenticate the request
#   * authorise the participant / tutor on a per-action basis
#   * translate BookingService errors into HTTP responses (flash + redirect)
#   * translate Booking state-machine errors into HTTP responses
class BookingsController < ApplicationController
  before_action :require_login
  before_action :set_booking, only: %i[show confirm cancel complete]
  before_action :authorize_tutor!, only: %i[confirm complete]
  before_action :authorize_participant!, only: %i[show cancel]

  rescue_from BookingService::BookingConflictError do |_e|
    redirect_to bookings_path,
                alert: t('flash.bookings.conflict', default: 'That slot was just taken — please pick another time.')
  end

  rescue_from BookingService::InvalidInputError do |e|
    redirect_to tutors_path, alert: e.message
  end

  rescue_from Booking::InvalidTransitionError do |e|
    redirect_to bookings_path, alert: e.message
  end

  # GET /bookings
  # Tutors see every booking attached to them.
  # Students see their own bookings.
  def index
    @bookings =
      if current_user.tutor?
        Booking.where(tutor_id: current_user.id).order(booking_date: :desc, start_time: :asc)
      else
        Booking.where(student_id: current_user.id).order(booking_date: :desc, start_time: :asc)
      end
  end

  # GET /bookings/:id
  def show; end

  # GET /bookings/new
  def new
    @booking = Booking.new
  end

  # POST /bookings
  # Delegates entirely to BookingService — the controller does no domain
  # validation. The service is the single entry point that the concurrency
  # tests exercise directly.
  def create
    booking_params = params[:booking].presence || {}
    result = BookingService.call(
      student: current_user,
      tutor_id: booking_params[:tutor_id].presence || params[:tutor_id],
      booking_date: booking_params[:booking_date] || params[:booking_date],
      start_time: booking_params[:start_time] || params[:start_time],
      end_time: booking_params[:end_time] || params[:end_time]
    )
    if result.success?
      redirect_to bookings_path, notice: t('flash.bookings.created', default: 'Booking requested.')
    else
      redirect_to tutors_path, alert: result.error_message
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  # PATCH /bookings/:id/confirm  — tutor only
  def confirm
    @booking.confirm!
    redirect_to bookings_path, notice: t('flash.bookings.confirmed', default: 'Booking confirmed.')
  end

  # PATCH /bookings/:id/cancel  — tutor or student
  def cancel
    @booking.cancel!
    redirect_to bookings_path, notice: t('flash.bookings.cancelled', default: 'Booking cancelled.')
  end

  # PATCH /bookings/:id/complete — tutor only
  def complete
    @booking.complete!
    redirect_to bookings_path, notice: t('flash.bookings.completed', default: 'Booking marked complete.')
  end

  private

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def authorize_tutor!
    return if @booking.tutor_id == current_user.id

    redirect_to(dashboard_path, alert: 'Only the assigned tutor can perform that action.')
  end

  def authorize_participant!
    return if @booking.student_id == current_user.id || @booking.tutor_id == current_user.id

    redirect_to(dashboard_path, alert: 'You are not a participant in that booking.')
  end
end
