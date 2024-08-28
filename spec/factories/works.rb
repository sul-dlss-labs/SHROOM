# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    title { title_fixture }
  end

  trait :with_druid do
    druid { druid_fixture }
  end

  trait :with_work_file do
    after(:create) do |work|
      create(:work_file, work:)
    end
  end
end
