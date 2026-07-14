# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TutorProfile, type: :model do
  describe 'validations' do
    subject { build(:tutor_profile) }

    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of(:subject) }

    it 'rejects a negative hourly_rate' do
      subject.hourly_rate = -1
      expect(subject).not_to be_valid
      expect(subject.errors[:hourly_rate]).to be_present
    end

    it 'enforces one profile per user' do
      user = create(:user, role: :tutor)
      create(:tutor_profile, user: user)
      duplicate = build(:tutor_profile, user: user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('has already been taken')
    end
  end

  describe '.search' do
    let!(:algebra) { create(:tutor_profile, subject: 'Algebra', headline: 'Master quadratics') }
    let!(:biology) { create(:tutor_profile, subject: 'Biology', headline: 'Cells and genes') }
    let!(:music)   { create(:tutor_profile, subject: 'Music Theory') }

    it 'returns everything when the query is blank' do
      expect(described_class.search.to_a).to contain_exactly(algebra, biology, music)
      expect(described_class.search(nil).to_a).to contain_exactly(algebra, biology, music)
      expect(described_class.search('').to_a).to contain_exactly(algebra, biology, music)
    end

    it 'matches case-insensitively on subject' do
      result = described_class.search('algebra').to_a
      expect(result).to contain_exactly(algebra)
    end

    it 'matches case-insensitively on headline' do
      result = described_class.search('QUADRATICS').to_a
      expect(result).to contain_exactly(algebra)
    end

    it 'is chainable with subsequent scopes' do
      result = described_class.search('biology').where(user_id: biology.user_id).to_a
      expect(result).to contain_exactly(biology)
    end
  end

  describe '#display_name' do
    it "includes the user's name and the subject" do
      profile = build(:tutor_profile, subject: 'Algebra')
      expect(profile.display_name).to include(profile.name, profile.subject)
      expect(profile.display_name).to eq("#{profile.user.name} — Algebra")
    end
  end
end
