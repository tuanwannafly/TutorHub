# frozen_string_literal: true

FactoryBot.define do
  sequence(:user_email) { |n| "user#{n}-#{SecureRandom.hex(3)}@tutorhub.test" }

  factory :user do
    email    { generate(:user_email) }
    name     { 'Pat Example' }
    password { 'password123' }
    password_confirmation { password }
    role { :student }
  end

  factory :tutor, class: 'User', parent: :user do
    role { :tutor }
  end
end
