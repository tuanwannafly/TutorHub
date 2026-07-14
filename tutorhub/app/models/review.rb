# frozen_string_literal: true

# Review is the post-session rating a student leaves for a tutor. It is
# strictly tied to a completed Booking: students cannot review a session
# that did not happen, and a given booking may only be reviewed once.
class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :reviewer, class_name: 'User'

  validates :rating, presence: true,
                     numericality: { only_integer: true, in: 1..5 }
  validates :reviewer, presence: true
  validates :booking_id, uniqueness: true
  validate  :booking_completed

  private

  def booking_completed
    return if booking&.completed?

    errors.add(:booking_id, 'must reference a completed booking')
  end
end
