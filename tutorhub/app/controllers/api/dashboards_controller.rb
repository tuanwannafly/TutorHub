# frozen_string_literal: true

module Api
  class DashboardsController < BaseController
    before_action :require_api_login!

    def show
      upcoming =
        if current_user.tutor?
          Booking.where(tutor_id: current_user.id)
                 .where('booking_date >= ?', Date.current)
                 .order(booking_date: :asc, start_time: :asc)
                 .limit(5)
        else
          Booking.where(student_id: current_user.id)
                 .where('booking_date >= ?', Date.current)
                 .order(booking_date: :asc, start_time: :asc)
                 .limit(5)
        end

      completed_count =
        if current_user.tutor?
          Booking.where(tutor_id: current_user.id, status: :completed).count
        else
          Booking.where(student_id: current_user.id, status: :completed).count
        end

      pending_count =
        if current_user.tutor?
          Booking.where(tutor_id: current_user.id, status: :pending).count
        else
          Booking.where(student_id: current_user.id, status: :pending).count
        end

      render_ok(
        user: Api::Presenters.user(current_user).merge(tutor_profile: Api::Presenters.tutor_profile(current_user.tutor_profile)),
        upcoming_bookings: upcoming.map { |b| Api::Presenters.booking(b) },
        stats: {
          completed: completed_count,
          pending: pending_count
        }
      )
    end
  end
end
