# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to be_valid }

    it 'requires an email' do
      subject.email = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("can't be blank")
    end

    it 'rejects invalid email formats' do
      subject.email = 'not-an-email'
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include('is not a valid email')
    end

    it 'downcases the email before save' do
      subject.email = '  Alice@Example.COM '
      subject.save!
      expect(subject.reload.email).to eq('alice@example.com')
    end

    it 'enforces case-insensitive uniqueness' do
      create(:user, email: 'dup@tutorhub.test')
      duplicate = build(:user, email: 'Dup@tutorhub.test')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('is already registered')
    end
  end

  describe 'password length validation' do
    it 'rejects passwords shorter than 6 characters' do
      user = build(:user, password: 'short', password_confirmation: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it 'accepts a 6-character password' do
      user = build(:user, password: 'abcdef', password_confirmation: 'abcdef')
      expect(user).to be_valid
    end

    it "rejects passwords longer than bcrypt's 72-byte limit" do
      long = 'a' * 73
      user = build(:user, password: long, password_confirmation: long)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to be_present
    end

    it 'leaves the password untouched when updating other fields' do
      user = create(:user)
      user.update!(name: 'New Name')
      expect(user.reload.name).to eq('New Name')
    end
  end

  describe '#role' do
    it 'defaults to student' do
      expect(User.new.role).to eq('student')
    end

    it 'exposes student? and tutor? predicates' do
      student = build(:user, role: :student)
      tutor   = build(:user, role: :tutor)

      expect(student).to be_student
      expect(student).not_to be_tutor
      expect(tutor).to be_tutor
      expect(tutor).not_to be_student
    end
  end

  describe '.authenticate' do
    let!(:user) do
      create(:user, email: 'findme@tutorhub.test', password: 'correctpw')
    end

    it 'returns the user on a correct, case-insensitive password' do
      expect(User.authenticate('FindMe@tutorhub.test', 'correctpw')).to eq(user)
    end

    it 'returns nil when the password is wrong' do
      expect(User.authenticate('findme@tutorhub.test', 'wrong')).to be_nil
    end

    it 'returns nil when the user does not exist' do
      expect(User.authenticate('nobody@tutorhub.test', 'correctpw')).to be_nil
    end

    it 'returns nil for blank inputs' do
      expect(User.authenticate(nil, 'x')).to be_nil
      expect(User.authenticate('x', nil)).to be_nil
      expect(User.authenticate('', '')).to be_nil
    end
  end
end
