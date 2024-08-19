# frozen_string_literal: true

FactoryBot.define do
  factory :work_file do
    after(:build) do |work_file|
      work_file.file.attach(
        io: Rails.root.join('spec/fixtures/files/preprint.pdf').open,
        filename: 'preprint.pdf',
        content_type: 'application/pdf'
      )
    end
  end
end
