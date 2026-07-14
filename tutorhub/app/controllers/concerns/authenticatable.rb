# frozen_string_literal: true

# Concise, Devise-less session handling.
#
# Controllers that include `Authenticatable` get:
#   * `current_user`   — memoised `User` for this request, or nil
#   * `user_signed_in?` / `logged_in?` — boolean aliases
#   * `require_login`  — `before_action` filter that bounces to /login
#   * `require_role(role)` — restricts an action to a given role name
#   * `login_as(user)` — sets `session[:user_id]`
#   * `logout`         — clears the session
#
# The session key (`session[:user_id]`) is documented here so it is easy to
# audit; everything else is plain Rails.
module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?, :logged_in? if respond_to?(:helper_method)
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    !current_user.nil?
  end
  alias logged_in? user_signed_in?

  def require_login
    return if user_signed_in?

    flash[:alert] = 'Please sign in to continue.'
    redirect_to login_path
  end

  def require_role(role)
    return if current_user&.public_send("#{role}?")

    redirect_to root_path, alert: "You don't have access to that page."
  end

  def login_as(user)
    reset_session
    session[:user_id] = user.id
    @current_user = user
  end

  def logout
    reset_session
    @current_user = nil
  end
end
