require 'rails_helper'

RSpec.describe ReportQuery do
  let(:tutor_user)  { create(:user, role: :tutor) }
  let(:profile)     { create(:tutor_profile, user: tutor_user, hourly_rate: 30) }
  let(:student)     { create(:user, role: :student) }

  describe '.available_tutors' do
    before do
      profile
      create(:availability, tutor_profile: profile, day_of_week: 1,
                            start_time: '10:00', end_time: '13:00')
    end

    it 'returns the tutor when slot fits inside an availability' do
      result = described_class.available_tutors(
        day_of_week: 1, start_time: '11:00', end_time: '12:00', limit: 5
      )
      expect(result.length).to eq(1)
      expect(result.first['name']).to eq(tutor_user.name)
    end

    it 'excludes tutors whose slot is fully booked' do
      monday = Date.current.next_occurring(:monday)
      create(:booking,
             student: student, tutor: tutor_user,
             booking_date: monday, start_time: '11:00', end_time: '12:00',
             status: :confirmed)

      result = described_class.available_tutors(
        day_of_week: 1, start_time: '11:00', end_time: '12:00', limit: 5
      )
      expect(result).to be_empty
    end

    it 'returns empty when day_of_week has no availabilities' do
      result = described_class.available_tutors(
        day_of_week: 5, start_time: '11:00', end_time: '12:00', limit: 5
      )
      expect(result).to be_empty
    end
  end

  describe '.monthly_revenue_per_tutor' do
    it 'sums totals per month for confirmed/completed bookings' do
      create(:booking, student: student, tutor: tutor_user, status: :confirmed, total_amount: 50)
      create(:booking, student: student, tutor: tutor_user, status: :completed, total_amount: 75)

      rows = described_class.monthly_revenue_per_tutor(
        start_date: 6.months.ago.to_date, end_date: 1.month.from_now.to_date
      )
      expect(rows.length).to be >= 1
      total = rows.sum { |r| r['total_revenue'].to_d }
      expect(total).to eq(125)
    end
  end

  describe '.top_tutors' do
    it 'ranks tutors by completed-bookings count' do
      busy_tutor = create(:user, role: :tutor)
      create(:tutor_profile, user: busy_tutor, hourly_rate: 40)
      create_list(:booking, 3, student: student, tutor: busy_tutor, status: :completed, total_amount: 50)

      result = described_class.top_tutors(limit: 5)
      expect(result.first['tutor_id']).to eq(busy_tutor.id)
      expect(result.first['booking_count'].to_i).to eq(3)
    end
  end
end
