class AvailabilitiesController < ApplicationController
  before_action :require_tutor
  before_action :load_tutor_profile, only: %i[index create]
  before_action :load_availability,  only: %i[destroy]

  # GET /availabilities
  def index
    @availabilities = @tutor_profile.availabilities.order(:day_of_week, :start_time)
    @availability   = @tutor_profile.availabilities.build
    @grouped        = @availabilities.group_by(&:day_of_week)
  end

  # POST /availabilities
  def create
    @availability = @tutor_profile.availabilities.build(availability_params)

    if @availability.save
      redirect_to availabilities_path, notice: 'Availability added.'
    else
      @availabilities = @tutor_profile.availabilities.order(:day_of_week, :start_time)
      @grouped        = @availabilities.group_by(&:day_of_week)
      render :index, status: :unprocessable_entity
    end
  end

  # DELETE /availabilities/:id
  def destroy
    @availability.destroy
    redirect_to availabilities_path, notice: 'Availability removed.'
  end

  private

  def require_tutor
    return if logged_in? && current_user&.tutor?

    redirect_to root_path, alert: 'Only tutors can manage availability.'
  end

  def load_tutor_profile
    @tutor_profile = current_user.tutor_profile
    return if @tutor_profile

    redirect_to root_path, alert: 'No tutor profile found for the current user.'
  end

  def load_availability
    @tutor_profile = current_user.tutor_profile
    return unless @tutor_profile

    @availability = @tutor_profile.availabilities.find_by(id: params[:id])
    return if @availability

    redirect_to availabilities_path, alert: 'Availability not found.'
  end

  def availability_params
    params.require(:availability).permit(:day_of_week, :start_time, :end_time)
  end
end
