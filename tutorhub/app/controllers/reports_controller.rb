# frozen_string_literal: true

# ReportsController — Renders three reports backed by ReportQuery.
#
# The heavy SQL lives in ReportQuery (written by another subagent). This
# controller is intentionally thin: it parses params, calls ReportQuery,
# and exposes the result to the view. If ReportQuery raises or is missing,
# the rescue blocks turn that into a clean flash message instead of a 500.
class ReportsController < ApplicationController
  before_action :require_login

  # GET /reports/tutors
  # Filters the tutor directory by availability for a given day + window.
  def tutors
    if params[:day_of_week].present?
      @result = ReportQuery.available_tutors(
        day_of_week: params[:day_of_week].to_i,
        start_time: params[:start_time],
        end_time: params[:end_time]
      )
    end
  rescue NoMethodError => e
    Rails.logger.warn("ReportQuery#available_tutors not implemented yet: #{e.message}")
    flash.now[:alert] = 'This report will be filled by ReportQuery.'
    @result = []
  end

  # GET /reports/revenue
  # Monthly revenue per tutor for the last 12 months.
  def revenue
    start_date = (Date.current - 12.months).beginning_of_month.to_date
    end_date   = Date.current

    @revenue = ReportQuery.monthly_revenue_per_tutor(
      start_date: start_date,
      end_date: end_date
    )
  rescue NoMethodError => e
    Rails.logger.warn("ReportQuery#monthly_revenue_per_tutor not implemented yet: #{e.message}")
    flash.now[:alert] = 'This report will be filled by ReportQuery.'
    @revenue = []
  end

  # GET /reports/top_tutors
  # Top N tutors by completed bookings (with avg rating + lifetime revenue).
  def top_tutors
    @top = ReportQuery.top_tutors(limit: 10)
  rescue NoMethodError => e
    Rails.logger.warn("ReportQuery#top_tutors not implemented yet: #{e.message}")
    flash.now[:alert] = 'This report will be filled by ReportQuery.'
    @top = []
  end
end
