# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :require_login

  def show
    # The view handles all role-specific rendering. We deliberately keep this
    # method empty — Sprint 1 is concerned with auth and the profile only.
  end
end
