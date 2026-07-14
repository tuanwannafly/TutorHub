# frozen_string_literal: true

module Api
  class ReportsController < BaseController
    before_action :require_api_login!

    def tutors
      rows =
        if params[:day_of_week].present?
          ReportQuery.available_tutors(
            day_of_week: params[:day_of_week].to_i,
            start_time: params[:start_time],
            end_time: params[:end_time]
          )
        else
          []
        end
      render_ok(rows: rows)
    rescue NoMethodError => e
      Rails.logger.warn("ReportQuery#available_tutors not implemented: #{e.message}")
      render_ok(rows: [])
    end

    def revenue
      start_date = (Date.current - 12.months).beginning_of_month.to_date
      end_date   = Date.current

      rows = ReportQuery.monthly_revenue_per_tutor(start_date: start_date, end_date: end_date)
      render_ok(rows: rows)
    rescue NoMethodError => e
      Rails.logger.warn("ReportQuery#monthly_revenue_per_tutor not implemented: #{e.message}")
      render_ok(rows: [])
    end

    def top_tutors
      rows = ReportQuery.top_tutors(limit: 10)
      render_ok(rows: rows)
    rescue NoMethodError => e
      Rails.logger.warn("ReportQuery#top_tutors not implemented: #{e.message}")
      render_ok(rows: [])
    end
  end
end
