FactoryBot.define do
  factory :availability do
    association :tutor_profile
    day_of_week { 1 } # Monday by default
    start_time { '10:00' }
    end_time   { '12:00' }
  end
end
