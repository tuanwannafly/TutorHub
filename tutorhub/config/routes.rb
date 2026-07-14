Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # ── JSON API (React frontend) ──────────────────────────────────────────────
  namespace :api do
    get  "lookups/days_of_week",   to: "lookups#days_of_week"
    get  "lookups/roles",          to: "lookups#roles"
    get  "lookups/booking_statuses", to: "lookups#booking_statuses"

    # Auth
    get    "session",  to: "sessions#show",   as: :api_session
    post   "session",  to: "sessions#create"
    delete "session",  to: "sessions#destroy"

    post   "signup",   to: "registrations#create", as: :api_signup

    # Public tutor directory
    resources :tutors, only: %i[index show], controller: "tutor_profiles"

    # Reports
    get "reports/tutors",     to: "reports#tutors"
    get "reports/revenue",    to: "reports#revenue"
    get "reports/top_tutors", to: "reports#top_tutors"

    # Authenticated resources
    get    "dashboard", to: "dashboards#show"

    resources :availabilities, only: %i[index create destroy]
    resources :bookings, only: %i[index show create] do
      member do
        patch :confirm
        patch :cancel
        patch :complete
      end
      resources :reviews, only: %i[create], shallow: true
    end
    resources :reviews, only: %i[show]
  end

  # ── HTML views (kept for the original Rails UI) ────────────────────────────
  # Auth
  get    "/login",  to: "sessions#new",      as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy",   as: :logout

  get    "/signup",          to: "registrations#new",     as: :signup
  post   "/registrations",   to: "registrations#create"

  # App root
  root "dashboards#show"

  get "/dashboard", to: "dashboards#show", as: :dashboard

  get "/reports/tutors",          to: "reports#tutors",          as: :reports_tutors
  get "/reports/revenue",         to: "reports#revenue",         as: :reports_revenue
  get "/reports/top_tutors",      to: "reports#top_tutors",      as: :reports_top_tutors

  resources :availabilities, only: %i[index create destroy]

  resources :bookings, only: %i[index show new create] do
    member do
      patch :confirm
      patch :cancel
      patch :complete
    end
    resources :reviews, only: %i[new create show], shallow: true
  end

  resources :reviews, only: %i[new create show]

  resources :tutors, only: %i[index show], controller: "tutor_profiles"
end