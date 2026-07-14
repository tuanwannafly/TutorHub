# frozen_string_literal: true

FactoryBot.define do
  factory :tutor_profile do
    association :user, factory: %i[user tutor]
    subject     { 'Algebra' }
    hourly_rate { 25.0 }
    headline    { 'Patient, maths-loving tutor.' }
    bio         { "I've taught Algebra 2 to dozens of students." }
  end
end
