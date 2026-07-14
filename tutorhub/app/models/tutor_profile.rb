# frozen_string_literal: true

# A TutorProfile is the public-facing description of a user who is offering
# tutoring. We keep it on its own table (rather than columns on `users`) so we
# can grow the public profile — availability slots, ratings, photos — without
# forcing `users` to carry columns that only apply to tutors. The unique index
# on `user_id` enforces the "one profile per tutor" invariant at the DB level.
#
# `search` is the entry point used by the public tutor directory. It returns
# an ActiveRecord::Relation so callers can layer additional constraints
# (pagination, subject filter, etc.) without losing chaining.
class TutorProfile < ApplicationRecord
  MAX_HEADLINE_LENGTH = 100
  MAX_BIO_LENGTH      = 1000

  belongs_to :user, optional: false

  has_many :availabilities, dependent: :destroy
  has_many :bookings, foreign_key: :tutor_id, dependent: :restrict_with_error

  delegate :name, :email, to: :user

  validates :subject,     presence: true
  validates :headline,    length: { maximum: MAX_HEADLINE_LENGTH }, allow_blank: true
  validates :bio,         length: { maximum: MAX_BIO_LENGTH },      allow_blank: true
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id,     uniqueness: true

  # Case-insensitive substring match on subject or headline. Uses ILIKE on
  # PostgreSQL; in tests this scope piggy-backs off ActiveRecord's
  # `connection.adapter_name` and still works on SQLite since we wrap it
  # with lower(...).
  def self.search(query = nil)
    relation = all
    return relation if query.blank?

    pattern = "%#{query.to_s.strip}%"
    relation.where(
      "lower(subject) LIKE :q OR lower(coalesce(headline, '')) LIKE :q",
      q: pattern.downcase
    )
  end

  def display_name
    "#{user.name} — #{subject}"
  end
end
