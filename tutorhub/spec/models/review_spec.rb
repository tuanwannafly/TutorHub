require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:tutor_user)   { create(:user, role: :tutor) }
  let(:profile)      { create(:tutor_profile, user: tutor_user) }
  let(:student_user) { create(:user, role: :student) }

  before do
    profile
    create(:availability, tutor_profile: profile, day_of_week: 1,
                          start_time: '10:00', end_time: '13:00')
  end

  let(:booking) do
    create(:booking, student: student_user, tutor: tutor_user, status: :completed)
  end

  it 'is valid for a completed booking' do
    review = build(:review, booking: booking, reviewer: student_user)
    expect(review).to be_valid
  end

  it 'rejects ratings below 1' do
    review = build(:review, booking: booking, reviewer: student_user, rating: 0)
    expect(review).not_to be_valid
  end

  it 'rejects ratings above 5' do
    review = build(:review, booking: booking, reviewer: student_user, rating: 6)
    expect(review).not_to be_valid
  end

  it 'rejects non-integer ratings' do
    review = build(:review, booking: booking, reviewer: student_user, rating: 3.5)
    expect(review).not_to be_valid
  end

  it 'requires a rating' do
    review = build(:review, booking: booking, reviewer: student_user, rating: nil)
    expect(review).not_to be_valid
  end

  it 'rejects reviews on bookings that are not completed' do
    booking.update!(status: :confirmed)
    review = build(:review, booking: booking, reviewer: student_user)
    expect(review).not_to be_valid
  end

  it 'enforces one review per booking (uniqueness)' do
    create(:review, booking: booking, reviewer: student_user)
    duplicate = build(:review, booking: booking, reviewer: student_user)
    expect(duplicate).not_to be_valid
  end
end
