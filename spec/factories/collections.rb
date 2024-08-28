# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    title { collection_title_fixture }
    druid { collection_druid_fixture }
  end
end
