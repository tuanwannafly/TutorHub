# frozen_string_literal: true

class RegistrationsController < ApplicationController
  def new
    redirect_to dashboard_path if user_signed_in?

    @user = User.new
    @user.role = params[:role].presence_in(%w[student tutor]) || 'student'

    if @user.tutor?
      @user.build_tutor_profile
    else
      @user.tutor_profile = nil # never allow a non-tutor sign-up to sneak one in
    end
  end

  def create
    @user = User.new(user_params)

    # We accept `role` from the form and only build the profile if the user
    # selected tutor. This keeps the controller forward-compatible with
    # student-only sign-up forms (e.g. OAuth shims) that omit `role`.
    ActiveRecord::Base.transaction do
      if @user.role.to_s != 'tutor'
        @user.tutor_profile = nil
      elsif @user.tutor_profile.nil?
        @user.build_tutor_profile
      end

      raise ActiveRecord::Rollback unless @user.save

      login_as(@user)
      flash[:notice] = 'Welcome to TutorHub!'
      redirect_to dashboard_path
    end

    return if performed?

    render :new, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit(
      :name, :email, :password, :password_confirmation, :role,
      tutor_profile_attributes: %i[subject headline hourly_rate bio]
    )
  end
end
