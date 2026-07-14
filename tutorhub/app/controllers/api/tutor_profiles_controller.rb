# frozen_string_literal: true

module Api
  class TutorProfilesController < BaseController
    def index
      query = params[:query].to_s.strip
      page = [params[:page].to_i, 1].max
      per_page = 12

      scope = TutorProfile.all.includes(:user)
      if query.present?
        like = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
        scope = scope.where(
          'subject ILIKE :q OR headline ILIKE :q OR bio ILIKE :q OR users.email ILIKE :q OR users.name ILIKE :q',
          q: like
        ).joins(:user)
      end

      total = scope.count
      profiles = scope.order(created_at: :desc)
                      .limit(per_page)
                      .offset((page - 1) * per_page)

      render_ok(
        tutors: profiles.map { |tp| Api::Presenters.tutor_profile(tp) },
        meta: {
          page: page,
          per_page: per_page,
          total: total,
          total_pages: (total.to_f / per_page).ceil
        }
      )
    end

    def show
      tp = TutorProfile.find(params[:id])
      availabilities = tp.availabilities.order(:day_of_week, :start_time)
      grouped = availabilities.group_by(&:day_of_week)

      render_ok(
        tutor: Api::Presenters.tutor_profile(tp),
        availabilities: availabilities.map { |a| Api::Presenters.availability(a) },
        availabilities_by_day: grouped.transform_values { |arr| arr.map { |a| Api::Presenters.availability(a) } }
      )
    end
  end
end
