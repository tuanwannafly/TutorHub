# frozen_string_literal: true

FactoryBot.define do
  factory :review do
    association :booking
    # Default reviewer is the student on the booking — sensible default
    # because only students are allowed to leave reviews on their bookings.
    reviewer     { booking&.student || association(:user, role: :student) }
    rating       { 5 }
    comment      { 'Great!' }
  end
end
