# frozen_string_literal: true

# The User model is the single authentication identity for TutorHub. A user is
# either a student who books sessions or a tutor who offers them. We use
# `has_secure_password` with bcrypt (no Devise) so the codebase is small and
# transparent. Email is normalised to lowercase before validation so
# `Alice@Example.com` and `alice@example.com` are treated as the same login,
# and the database unique index on `lower(email)` enforces it authoritatively.
#
# The `role` column is an integer that Rails 7.1's `enum` macro turns into a
# small set of named predicates (`student?`, `tutor?`) and scopes
# (`User.student`, `User.tutor`). Keeping it as an integer makes it easy to add
# more roles in future migrations without rewriting every record.
class User < ApplicationRecord
  PASSWORD_MIN = 6
  PASSWORD_MAX = 72 # bcrypt's hard input limit

  has_secure_password

  enum :role, { student: 0, tutor: 1 }, default: :student

  has_one :tutor_profile, dependent: :destroy

  before_validation :normalize_email

  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }

  validates :name, presence: true

  validates :password,
            length: { in: PASSWORD_MIN..PASSWORD_MAX },
            allow_nil: true

  # Class-level convenience used by SessionsController#create and tests.
  # Returns the user whose email matches (case-insensitively) and whose
  # password authenticates, or nil when either check fails.
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?

    user = find_by('lower(email) = ?', email.to_s.downcase.strip)
    return nil unless user

    authenticated = user.authenticate(password)
    authenticated ? user : nil
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
