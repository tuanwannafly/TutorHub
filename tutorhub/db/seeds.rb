# Seeds for TutorHub.
#
# Creates:
#   - 4 tutors (alice, bob, carol, dave) with tutor_profiles and varied availability
#   - 3 students (sam, jane, ken)
#   - A handful of bookings in different statuses for the demo dashboard
#
# Idempotent: uses find_or_create_by so you can re-run safely.

require 'time'

puts '[seeds] Creating users ...'

TUTORS = [
  { name: 'Alice Nguyen', email: 'alice@tutorhub.dev',   subject: 'Mathematics',
    headline: 'Calculus, Linear Algebra', hourly_rate: 35.0, bio: '10 years teaching high school & university math.' },
  { name: 'Bob Smith',    email: 'bob@tutorhub.dev',     subject: 'English',
    headline: 'IELTS / TOEIC / Academic writing', hourly_rate: 28.0, bio: 'Cambridge-certified, exam-prep specialist.' },
  { name: 'Carol Tran',   email: 'carol@tutorhub.dev',   subject: 'Physics',
    headline: 'From classical mechanics to QM',         hourly_rate: 45.0, bio: 'PhD, MIT, 5 years of online tutoring.' },
  { name: 'Dave Pham',    email: 'dave@tutorhub.dev',    subject: 'Programming',
    headline: 'Ruby on Rails & Data Structures',        hourly_rate: 50.0, bio: 'Senior engineer, interviewed 100s.' }
].freeze

PASSWORD = 'password123'.freeze

TUTORS.each do |attrs|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name  = attrs[:name]
    u.role  = :tutor
    u.password = PASSWORD
    u.password_confirmation = PASSWORD
  end

  user.tutor_profile || user.create_tutor_profile!(
    subject: attrs[:subject],
    headline: attrs[:headline],
    hourly_rate: attrs[:hourly_rate],
    bio: attrs[:bio]
  )
end

puts '[seeds] Creating students ...'

STUDENTS = [
  { name: 'Sam Vo',   email: 'student1@tutorhub.dev' },
  { name: 'Jane Doe', email: 'student2@tutorhub.dev' },
  { name: 'Ken Le',   email: 'student3@tutorhub.dev' }
].freeze

STUDENTS.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.role = :student
    u.password = PASSWORD
    u.password_confirmation = PASSWORD
  end
end

puts '[seeds] Creating availabilities ...'

# Monday through Friday, 09:00–17:00, broken into 2-hour slots for Alice.
alice = User.find_by(email: 'alice@tutorhub.dev')
if alice&.tutor_profile && alice.tutor_profile.availabilities.empty?
  [1, 2, 3, 4, 5].each do |day|
    %w[09:00 11:00 13:00 15:00].each do |start_time|
      end_time = (Time.parse(start_time) + 2.hours).strftime('%H:%M')
      alice.tutor_profile.availabilities.create!(
        day_of_week: day,
        start_time: start_time,
        end_time: end_time
      )
    end
  end
end

puts '[seeds] Creating sample bookings ...'

student = User.find_by(email: 'student1@tutorhub.dev')
if alice && student && Booking.where(student: student, tutor: alice).none?
  # Confirmed booking two weeks ago
  past = 2.weeks.ago.to_date.next_occurring(:monday)
  Booking.create!(
    student: student, tutor: alice,
    booking_date: past, start_time: '10:00', end_time: '11:00',
    status: :completed, total_amount: 35.0
  )
end

if alice && student && Booking.where(student: student, tutor: alice, status: :confirmed).none?
  upcoming = 1.week.from_now.to_date.next_occurring(:wednesday)
  Booking.create!(
    student: student, tutor: alice,
    booking_date: upcoming, start_time: '15:00', end_time: '17:00',
    status: :confirmed, total_amount: 35.0
  )
end

puts "[seeds] Done. Sign-in: alice@tutorhub.dev / #{PASSWORD}"
