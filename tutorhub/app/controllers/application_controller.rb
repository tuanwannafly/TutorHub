# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authenticatable

  # The `helper_method` declarations inside Authenticatable only register when
  # the controller responds to it. Belt + braces in case the application
  # controller is later swapped to an ActionController::API variant.
  helper_method :current_user, :user_signed_in?, :logged_in?
end
