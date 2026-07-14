# frozen_string_literal: true

# CORS for the JSON API. The React frontend runs on a different origin during
# development (e.g. http://localhost:5173) and so needs credentialed CORS for
# the cookie-based session. In production both apps share an origin (or sit
# behind a reverse proxy) and these headers are largely no-ops.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins [
      "http://localhost:5173",
      "http://127.0.0.1:5173",
      "http://localhost:3001",
      "http://127.0.0.1:3001",
      # Allow any origin in production when serving both apps from one host
      # (e.g. Render/Fly). Restrict in real deployments.
      /.*/
    ]
    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true,
             expose: ["CSRF-Token"]
  end
end