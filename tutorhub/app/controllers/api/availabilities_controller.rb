# frozen_string_literal: true

module Api
  class AvailabilitiesController < BaseController
    before_action :require_api_login!
    before_action :require_tutor_role!

    def index
      grouped = current_user.tutor_profile.availabilities.order(:day_of_week, :start_time).group_by(&:day_of_week)

      render_ok(
        availabilities: current_user.tutor_profile.availabilities.order(:day_of_week, :start_time).map do |a|
          Api::Presenters.availability(a)
        end,
        availabilities_by_day: grouped.transform_values { |arr| arr.map { |a| Api::Presenters.availability(a) } }
      )
    end

    def create
      a = current_user.tutor_profile.availabilities.build(availability_params)
      if a.save
        render_ok(Api::Presenters.availability(a), status: :created)
      else
        render_error(:unprocessable_entity, 'Could not save availability.', details: a.errors.as_json)
      end
    end

    def destroy
      a = current_user.tutor_profile.availabilities.find_by(id: params[:id])
      return render_error(:not_found, 'Availability not found.') unless a

      a.destroy
      render_ok(message: 'Availability removed.')
    end

    private

    def require_tutor_role!
      return render_error(:forbidden, 'Only tutors can manage availability.') unless current_user&.tutor?

      return if current_user.tutor_profile

      render_error(:unprocessable_entity, 'No tutor profile found for the current user.')
    end

    def availability_params
      params.require(:availability).permit(:day_of_week, :start_time, :end_time)
    end
  end
end
