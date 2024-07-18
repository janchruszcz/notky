# frozen_string_literal: true

FactoryBot.define do
  factory :todo do
    title { 'Clean the house' }
    list { association :list }
  end
end
