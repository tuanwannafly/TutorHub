require 'rails_helper'

RSpec.describe BookingService, type: :service do
  describe '.call' do
    let(:tutor_user)  { create(:user, role: :tutor) }
    let(:profile)     { create(:tutor_profile, user: tutor_user) }
    let(:student_user) { create(:user, role: :student) }

    let(:monday) { Date.current.next_occurring(:monday) }
    let(:availability) do
      create(:availability, tutor_profile: profile, day_of_week: 1,
                            start_time: '10:00', end_time: '13:00')
    end

    before { availability }

    it 'creates a pending booking on a valid slot' do
      result = described_class.call(
        student: student_user, tutor_id: tutor_user.id,
        booking_date: monday, start_time: '11:00', end_time: '12:00'
      )
      expect(result.success?).to eq(true)
      expect(result.booking).to be_persisted
      expect(result.booking.status).to eq('pending')
      expect(result.booking.total_amount).to eq(profile.hourly_rate)
    end

    it 'raises InvalidInputError for past dates' do
      expect do
        described_class.call(
          student: student_user, tutor_id: tutor_user.id,
          booking_date: 2.days.ago, start_time: '11:00', end_time: '12:00'
        )
      end.to raise_error(BookingService::InvalidInputError, /future/i)
    end

    it 'raises InvalidInputError when slot does not match availability' do
      expect do
        described_class.call(
          student: student_user, tutor_id: tutor_user.id,
          booking_date: monday, start_time: '08:00', end_time: '09:00'
        )
      end.to raise_error(BookingService::InvalidInputError, /availability/i)
    end

    it 'raises InvalidInputError when booking self' do
      profile # ensure exists
      expect do
        described_class.call(
          student: tutor_user, tutor_id: tutor_user.id,
          booking_date: monday, start_time: '11:00', end_time: '12:00'
        )
      end.to raise_error(BookingService::InvalidInputError)
    end

    it 'raises BookingConflictError when the same slot is double-INSERTed' do
      # First booking succeeds
      described_class.call(
        student: student_user, tutor_id: tutor_user.id,
        booking_date: monday, start_time: '11:00', end_time: '12:00'
      )

      # Second student tries same slot — DB UNIQUE INDEX must kick in.
      other_student = create(:user, role: :student)
      expect do
        described_class.call(
          student: other_student, tutor_id: tutor_user.id,
          booking_date: monday, start_time: '11:00', end_time: '12:00'
        )
      end.to raise_error(BookingService::BookingConflictError)
    end

    it 'concurrency: only one of two parallel bookings succeeds', :concurrency do
      # Manually create 5 attempts in threads to simulate a stampede.
      results = []
      threads = 5.times.map do
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            results << described_class.call(
              student: student_user, tutor_id: tutor_user.id,
              booking_date: monday, start_time: '11:00', end_time: '12:00'
            )
          rescue BookingService::BookingConflictError => e
            results << e
          end
        end
      end
      threads.each(&:join)

      successes = results.count { |r| r.is_a?(BookingService::Result) && r.success? }
      expect(successes).to eq(1)
      expect(Booking.where(tutor_id: tutor_user.id, booking_date: monday, start_time: '11:00').count).to eq(1)
    end
  end
end
