require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:tutor_user)   { create(:user, role: :tutor) }
  let(:profile)      { create(:tutor_profile, user: tutor_user) }
  let(:student_user) { create(:user, role: :student) }

  before { profile }

  describe 'validations' do
    it 'is valid with valid attrs' do
      booking = build(:booking, student: student_user, tutor: tutor_user)
      expect(booking).to be_valid
    end

    it 'is invalid when end_time is not after start_time' do
      booking = build(:booking, student: student_user, tutor: tutor_user,
                                start_time: '11:00', end_time: '10:00')
      expect(booking).not_to be_valid
    end

    it 'does not allow booking yourself' do
      booking = build(:booking, student: tutor_user, tutor: tutor_user)
      expect(booking).not_to be_valid
    end

    it 'rejects a student as the tutor' do
      booking = build(:booking, student: student_user, tutor: student_user)
      expect(booking).not_to be_valid
    end

    it 'rejects a tutor as the student' do
      booking = build(:booking, student: tutor_user, tutor: tutor_user)
      expect(booking).not_to be_valid
    end
  end

  describe 'enum' do
    it 'defines all four statuses' do
      expect(Booking.statuses.keys).to match_array(%w[pending confirmed completed cancelled])
    end

    it 'starts in :pending' do
      booking = create(:booking, student: student_user, tutor: tutor_user)
      expect(booking.status).to eq('pending')
    end
  end

  describe 'state machine' do
    let(:booking) { create(:booking, student: student_user, tutor: tutor_user, status: :pending) }

    it 'transitions pending -> confirmed -> completed' do
      expect(booking.confirm!).to be_truthy
      expect(booking.reload).to be_confirmed
      expect(booking.complete!).to be_truthy
      expect(booking.reload).to be_completed
    end

    it 'confirm! raises InvalidTransitionError when not pending' do
      booking.update!(status: :cancelled)
      expect { booking.confirm! }.to raise_error(Booking::InvalidTransitionError)
    end

    it 'confirm! raises InvalidTransitionError when already confirmed' do
      booking.update!(status: :confirmed)
      expect { booking.confirm! }.to raise_error(Booking::InvalidTransitionError)
    end

    it 'complete! raises InvalidTransitionError when not confirmed' do
      expect { booking.complete! }.to raise_error(Booking::InvalidTransitionError, /confirmed/)
    end

    it 'cancel! works from pending' do
      booking.cancel!
      expect(booking.reload).to be_cancelled
    end

    it 'cancel! works from confirmed' do
      booking.update!(status: :confirmed)
      booking.cancel!
      expect(booking.reload).to be_cancelled
    end

    it 'cancel! raises InvalidTransitionError from completed' do
      booking.update!(status: :completed)
      expect { booking.cancel! }.to raise_error(Booking::InvalidTransitionError)
    end

    it 'transitions chain (pending -> confirmed -> completed) returns truthy each time' do
      expect(booking.confirm!).to be_truthy
      expect(booking.complete!).to be_truthy
    end
  end
end
