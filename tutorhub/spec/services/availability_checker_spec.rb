require 'rails_helper'

RSpec.describe AvailabilityChecker do
  let(:tutor_profile) { create(:tutor_profile) }

  def call_checker(start_time:, end_time:, day_of_week: 1)
    AvailabilityChecker.call(
      tutor_profile: tutor_profile,
      day_of_week: day_of_week,
      start_time: start_time,
      end_time: end_time
    )
  end

  context 'when the requested slot fits inside an existing window of equal length' do
    before do
      create(:availability,
             tutor_profile: tutor_profile,
             day_of_week: 1,
             start_time: '10:00',
             end_time: '12:00')
    end

    it 'returns available? true' do
      result = call_checker(start_time: '10:00', end_time: '12:00')
      expect(result.available?).to be(true)
      expect(result.reason).to eq(:ok)
    end
  end

  context 'when there is no availability window for the requested day' do
    before do
      create(:availability,
             tutor_profile: tutor_profile,
             day_of_week: 2, # Tuesday
             start_time: '10:00',
             end_time: '12:00')
    end

    it 'returns available? false with reason :no_matching_window' do
      result = call_checker(start_time: '10:00', end_time: '11:00', day_of_week: 1) # Monday
      expect(result.available?).to be(false)
      expect(result.reason).to eq(:no_matching_window)
    end
  end

  context 'when the requested slot extends past the availability window end' do
    before do
      create(:availability,
             tutor_profile: tutor_profile,
             day_of_week: 1,
             start_time: '10:00',
             end_time: '12:00')
    end

    it 'returns available? false' do
      result = call_checker(start_time: '11:30', end_time: '13:00')
      expect(result.available?).to be(false)
      expect(result.reason).to eq(:no_matching_window)
    end
  end

  context 'when the requested slot starts before the availability window start' do
    before do
      create(:availability,
             tutor_profile: tutor_profile,
             day_of_week: 1,
             start_time: '10:00',
             end_time: '12:00')
    end

    it 'returns available? false' do
      result = call_checker(start_time: '09:00', end_time: '11:00')
      expect(result.available?).to be(false)
      expect(result.reason).to eq(:no_matching_window)
    end
  end
end
