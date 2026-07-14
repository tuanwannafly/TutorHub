# frozen_string_literal: true

# Each booking is uniquely identified by (tutor_id, booking_date, start_time)
# — the DB-level unique index will reject duplicates inside the same test.
#
# We provide both a global sequence (for default booking creation) and a
# transient `slot_index` that tests can override when they need precise
# control over the date+time combination.
#
# Slot layout: 6 daily start times (08, 10, 12, 14, 16, 18), bumping the
# date forward by one day every 6 increments. This gives 180 unique slots
# before wrap-around — more than enough for any one example.
FactoryBot.define do
  sequence(:booking_slot_index) { |n| n }

  factory :booking do
    transient do
      slot_index { generate(:booking_slot_index) }
    end

    booking_date { (slot_index / 6 + 1).days.from_now.to_date }
    start_time   { format('%02d:00', 8 + (slot_index % 6) * 2) }
    end_time     { format('%02d:00', 10 + (slot_index % 6) * 2) }

    association :student, factory: %i[user student]
    association :tutor,   factory: %i[user tutor]

    status       { :pending }
    total_amount { 25.0 }
    lock_version { 0 }
  end
end
