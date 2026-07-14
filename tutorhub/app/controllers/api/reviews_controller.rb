# frozen_string_literal: true

module Api
  class ReviewsController < BaseController
    before_action :require_api_login!

    def show
      review = Review.find(params[:id])
      render_ok(Api::Presenters.review(review))
    end

    def create
      booking = Booking.find(params[:booking_id])

      unless booking.completed? &&
             booking.student_id == current_user.id &&
             booking.review.nil?
        return render_error(:forbidden, 'Review must be 1–5 stars and tied to a completed booking.')
      end

      review = booking.build_review(reviewer: current_user)
      if review.update(review_params)
        render_ok(Api::Presenters.review(review), status: :created)
      else
        render_error(:unprocessable_entity, 'Could not save review.', details: review.errors.as_json)
      end
    end

    private

    def review_params
      params.require(:review).permit(:rating, :comment)
    end
  end
end
