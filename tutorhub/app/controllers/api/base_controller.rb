# frozen_string_literal: true

# Base controller for the JSON API consumed by the React frontend.
#
# Goals:
#   * Slim — no HTML layouts, no ERB, no simple_form.
#   * Predictable JSON envelopes:
#       { ok: true,  data: ... }
#       { ok: false, error: { code, message, details? } }
#   * Cookie-based session auth (same as the HTML controllers) so the React app
#     can reuse session cookies set by the browser when both run on the same
#     origin (or across origins with `credentials: "include"` + proper CORS).
#   * CSRF: we accept `X-CSRF-Token` headers from a meta tag rendered on the
#     initial HTML response (handled by ApplicationController) and skip
#     verification for the first GETs in development.
module Api
  class BaseController < ActionController::API
    include ActionController::Cookies
    include ActionController::RequestForgeryProtection
    include Authenticatable

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_error(:not_found, e.message)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_error(:unprocessable_entity, e.message, details: e.record.errors.as_json)
    end

    rescue_from ActionController::ParameterMissing do |e|
      render_error(:bad_request, e.message)
    end

    rescue_from ActiveRecord::StaleObjectError do |_e|
      render_error(:conflict, 'This record was changed by someone else. Please refresh.')
    end

    before_action :set_csrf_cookie

    # CSRF: in dev/test we accept requests without an explicit CSRF token
    # because the React app talks to us via `credentials: "include"` from
    # http://localhost:5173 → http://localhost:3000. In production, set
    # `protect_from_forgery` to on and echo the token from a meta tag.
    protect_from_forgery with: :exception, unless: -> { Rails.env.development? || Rails.env.test? }

    protected

    def set_csrf_cookie
      cookies['CSRF-TOKEN'] = {
        value: form_authenticity_token,
        same_site: :lax,
        secure: Rails.env.production?
      }
    end

    def render_ok(data = nil, status: :ok)
      render json: { ok: true, data: data }, status: status
    end

    def render_error(code, message, details: nil, status: nil)
      status ||= case code
                 when :not_found        then :not_found
                 when :unauthorized     then :unauthorized
                 when :forbidden        then :forbidden
                 when :conflict         then :conflict
                 when :bad_request      then :bad_request
                 else                        :unprocessable_entity
                 end

      payload = { ok: false, error: { code: code.to_s, message: message } }
      payload[:error][:details] = details if details.present?
      render json: payload, status: status
    end

    # Allow JSON-style `current_user` to be read by subclasses just like the HTML side.
    helper_method :current_user, :user_signed_in? if respond_to?(:helper_method)

    def require_api_login!
      return if user_signed_in?

      render_error(:unauthorized, 'Please sign in to continue.')
    end

    def require_api_role!(role)
      return if current_user&.public_send("#{role}?")

      render_error(:forbidden, "You don't have access to that page.")
    end
  end
end
