# frozen_string_literal: true

module Api
  class SessionsController < BaseController
    def create
      user = User.authenticate(params[:email], params[:password])
      if user
        login_as(user)
        render_ok(Api::Presenters.user(user).merge(tutor_profile: Api::Presenters.tutor_profile(user.tutor_profile)))
      else
        render_error(:unauthorized, 'Email or password is incorrect.')
      end
    end

    def destroy
      logout
      render_ok(message: 'Signed out.')
    end

    def show
      if user_signed_in?
        render_ok(
          Api::Presenters.user(current_user).merge(
            tutor_profile: Api::Presenters.tutor_profile(current_user.tutor_profile)
          )
        )
      else
        render_error(:unauthorized, 'Not signed in.')
      end
    end
  end
end
