# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'jan@notky.io' }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
