# frozen_string_literal: true

# Tiny presenters that turn ActiveRecord objects into plain hashes.
#
# We keep these in one file so the React side has one place to look up the
# JSON shape of every entity.
module Api
  module Presenters
    module_function

    def user(u)
      return nil unless u

      {
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role,
        role_label: u.role.to_s.titleize,
        created_at: u.created_at
      }
    end

    def tutor_profile(tp, include_user: true)
      return nil unless tp

      {
        id: tp.id,
        user_id: tp.user_id,
        subject: tp.subject,
        headline: tp.headline,
        hourly_rate: tp.hourly_rate.to_f,
        bio: tp.bio,
        display_name: tp.display_name,
        average_rating: tp.respond_to?(:average_rating) ? tp.average_rating : nil,
        review_count: tp.respond_to?(:review_count) ? tp.review_count : nil,
        user: include_user ? user(tp.user) : nil
      }
    end

    def availability(a)
      return nil unless a

      {
        id: a.id,
        tutor_profile_id: a.tutor_profile_id,
        day_of_week: a.day_of_week,
        day_name: a.day_name,
        start_time: a.start_time.strftime('%H:%M'),
        end_time: a.end_time.strftime('%H:%M'),
        length_minutes: a.length_minutes
      }
    end

    def booking(b)
      return nil unless b

      {
        id: b.id,
        student_id: b.student_id,
        tutor_id: b.tutor_id,
        booking_date: b.booking_date.to_s,
        start_time: b.start_time.strftime('%H:%M'),
        end_time: b.end_time.strftime('%H:%M'),
        status: b.status,
        status_label: b.status.titleize,
        total_amount: b.total_amount.to_f,
        length_minutes: b.length_minutes,
        tutor: user(b.tutor),
        student: user(b.student),
        subject: b.tutor.tutor_profile&.subject,
        review: b.review ? review(b.review) : nil
      }
    end

    def review(r)
      return nil unless r

      {
        id: r.id,
        booking_id: r.booking_id,
        rating: r.rating,
        comment: r.comment,
        created_at: r.created_at
      }
    end
  end
end
