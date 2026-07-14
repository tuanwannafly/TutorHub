# frozen_string_literal: true

# ReviewsController — Lets a student rate + comment on a *completed* booking.
#
# Authorisation is intentionally tight: only the student who owns a completed
# booking, and only while that booking has no review yet, may submit a review.
# Tutor-self-reviews are not allowed.
class ReviewsController < ApplicationController
  before_action :require_login
  before_action :set_booking

  # GET /bookings/:booking_id/reviews/new
  def new
    unless authorized_to_review?
      return redirect_to(dashboard_path,
                         alert: t('flash.reviews.invalid',
                                  default: 'Review must be 1–5 stars and tied to a completed booking.'))
    end

    @review = @booking.build_review(reviewer: current_user)
  end

  # POST /bookings/:booking_id/reviews
  def create
    unless authorized_to_review?
      return redirect_to(dashboard_path,
                         alert: t('flash.reviews.invalid',
                                  default: 'Review must be 1–5 stars and tied to a completed booking.'))
    end

    @review = @booking.build_review(reviewer: current_user)
    if @review.update(review_params)
      redirect_to booking_path(@booking), notice: t('flash.reviews.created', default: 'Thanks for your review!')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /reviews/:id (and /bookings/:booking_id/reviews/:id)
  def show
    redirect_to bookings_path if @booking.nil?
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id] || params[:id])
  end

  def authorized_to_review?
    @booking.present? &&
      @booking.completed? &&
      @booking.student_id == current_user.id &&
      @booking.review.nil?
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
