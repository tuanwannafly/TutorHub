class TutorProfilesController < ApplicationController
  # GET /tutors
  def index
    query = params[:query].to_s.strip
    scope = TutorProfile.all

    if query.present?
      like = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope = scope.where(
        'subject ILIKE :q OR headline ILIKE :q OR bio ILIKE :q OR users.email ILIKE :q',
        q: like
      ).joins(:user)
    end

    @total_count = scope.count
    @per_page    = 12
    @page        = [params[:page].to_i, 1].max
    @tutor_profiles = scope
                      .order(created_at: :desc)
                      .limit(@per_page)
                      .offset((@page - 1) * @per_page)
  end

  # GET /tutors/:id
  def show
    @tutor_profile   = TutorProfile.find(params[:id])
    @availabilities  = @tutor_profile.availabilities.order(:day_of_week, :start_time)
    @grouped         = @availabilities.group_by(&:day_of_week)
  end
end
