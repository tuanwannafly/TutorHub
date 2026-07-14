# frozen_string_literal: true

module Api
  class RegistrationsController < BaseController
    def create
      user = User.new(user_params)
      ActiveRecord::Base.transaction do
        if user.role.to_s != 'tutor'
          user.tutor_profile = nil
        elsif user.tutor_profile.nil?
          user.build_tutor_profile
        end

        raise ActiveRecord::Rollback unless user.save

        login_as(user)
      end

      if user.persisted?
        render_ok(
          Api::Presenters.user(user).merge(
            tutor_profile: Api::Presenters.tutor_profile(user.tutor_profile)
          ),
          status: :created
        )
      else
        render_error(:unprocessable_entity, 'Could not create account.', details: user.errors.as_json)
      end
    end

    private

    def user_params
      params.require(:user).permit(
        :name, :email, :password, :password_confirmation, :role,
        tutor_profile_attributes: %i[subject headline hourly_rate bio]
      )
    end
  end
end
