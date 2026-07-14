# frozen_string_literal: true

module Api
  class LookupsController < BaseController
    # Public utility endpoints used by the React frontend for static metadata.
    def days_of_week
      render_ok(Availability::DAYS_OF_WEEK.map { |n, label| { value: n, label: label } })
    end

    def roles
      render_ok(User.roles.keys.map { |k| { value: k, label: k.titleize } })
    end

    def booking_statuses
      render_ok(Booking.statuses.keys.map { |k| { value: k, label: k.titleize } })
    end
  end
end
