require 'rails_helper'

RSpec.describe 'Booking flow', type: :request do
  let(:tutor_user)  { create(:user, role: :tutor) }
  let(:profile)     { create(:tutor_profile, user: tutor_user, hourly_rate: 30) }
  let(:other_tutor) { create(:user, role: :tutor) }
  let(:student)     { create(:user, role: :student) }
  let(:other_student) { create(:user, role: :student) }

  let(:monday) { Date.current.next_occurring(:monday) }

  let!(:availability) do
    create(:availability, tutor_profile: profile, day_of_week: 1,
                          start_time: '10:00', end_time: '13:00')
  end

  before do
    # Sign in the student by default. Individual tests can override this by
    # calling `login_as(other_user)` which writes session[:user_id] directly.
    login_as(student)
  end

  describe 'POST /bookings' do
    it 'creates a pending booking for a valid slot (happy path)' do
      expect do
        post '/bookings', params: {
          booking: {
            tutor_id: tutor_user.id,
            booking_date: monday,
            start_time: '11:00',
            end_time: '12:00'
          }
        }
      end.to change(Booking, :count).by(1)

      expect(response).to redirect_to(bookings_path)
      expect(Booking.last.status).to eq('pending')
    end

    it 'does not double-book when two requests hit at once', :concurrency do
      threads = []
      results = []
      2.times do
        threads << Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            login_as(other_student)
            begin
              post '/bookings', params: {
                booking: { tutor_id: tutor_user.id, booking_date: monday, start_time: '11:00', end_time: '12:00' }
              }
              results << response.status
            rescue StandardError => e
              results << e
            end
          end
        end
      end
      threads.each(&:join)

      expect(Booking.where(tutor_id: tutor_user.id, booking_date: monday, start_time: '11:00').count).to eq(1)
    end
  end

  describe 'PATCH /bookings/:id/confirm' do
    it 'lets the tutor confirm a pending booking' do
      booking = create(:booking, student: student, tutor: tutor_user,
                                 booking_date: 1.week.from_now.to_date,
                                 start_time: '11:00', end_time: '12:00')
      login_as(tutor_user)
      patch "/bookings/#{booking.id}/confirm"
      expect(booking.reload.status).to eq('confirmed')
    end
  end
end
