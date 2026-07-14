require 'rails_helper'

RSpec.describe Availability, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      availability = build(:availability)
      expect(availability).to be_valid
    end

    it 'is invalid when end_time equals start_time' do
      availability = build(:availability, start_time: '10:00', end_time: '10:00')
      expect(availability).not_to be_valid
      expect(availability.errors[:end_time]).to be_present
    end

    it 'is invalid when end_time is before start_time' do
      availability = build(:availability, start_time: '12:00', end_time: '10:00')
      expect(availability).not_to be_valid
      expect(availability.errors[:end_time]).to be_present
    end

    it 'is invalid when day_of_week is 7 (out of range 0..6)' do
      availability = build(:availability, day_of_week: 7)
      expect(availability).not_to be_valid
      expect(availability.errors[:day_of_week]).to be_present
    end

    it 'is invalid when day_of_week is negative' do
      availability = build(:availability, day_of_week: -1)
      expect(availability).not_to be_valid
      expect(availability.errors[:day_of_week]).to be_present
    end

    it 'is invalid when it overlaps an existing availability for the same tutor and day' do
      tutor = create(:tutor_profile)
      create(:availability,
             tutor_profile: tutor,
             day_of_week: 1,
             start_time: '10:00',
             end_time: '12:00')

      overlap = build(:availability,
                      tutor_profile: tutor,
                      day_of_week: 1,
                      start_time: '11:00',
                      end_time: '13:00')

      expect(overlap).not_to be_valid
      expect(overlap.errors[:base]).to be_present
    end

    it 'is valid when a non-overlapping window exists for the same tutor and day' do
      tutor = create(:tutor_profile)
      create(:availability,
             tutor_profile: tutor,
             day_of_week: 1,
             start_time: '10:00',
             end_time: '12:00')

      non_overlap = build(:availability,
                          tutor_profile: tutor,
                          day_of_week: 1,
                          start_time: '14:00',
                          end_time: '16:00')

      expect(non_overlap).to be_valid
    end
  end

  describe '#length_minutes' do
    it 'returns the duration in minutes between start_time and end_time' do
      availability = build(:availability, start_time: '10:00', end_time: '12:30')
      expect(availability.length_minutes).to eq(150)
    end

    it 'returns zero for an empty window' do
      availability = build(:availability, start_time: '10:00', end_time: '10:00')
      expect(availability.length_minutes).to eq(0)
    end
  end

  describe '.for_day scope' do
    it 'returns only availabilities for the requested day_of_week' do
      tutor = create(:tutor_profile)
      monday = create(:availability, tutor_profile: tutor, day_of_week: 1, start_time: '09:00', end_time: '11:00')
      _tuesday = create(:availability, tutor_profile: tutor, day_of_week: 2, start_time: '09:00', end_time: '11:00')

      expect(Availability.for_day(1)).to include(monday)
      expect(Availability.for_day(1)).not_to include(_tuesday)
    end
  end
end
