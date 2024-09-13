# frozen_string_literal: true

namespace :export do
  desc 'Exports metadata as CSV for Works in a Collection'
  task :csv, [:collection_druid] => :environment do |_t, args|
    collection = Collection.find_by!(druid: args[:collection_druid])

    rows = CsvService.call(works: collection.works.where.not(druid: nil))
    CSV.open('export.csv', 'w') do |csv|
      rows.each { |row| csv << row }
    end

    puts 'Exported to export.csv'
  end

  desc 'Exports metadata as line-oriented JSON for Works in a Collection'
  task :json, [:collection_druid] => :environment do |_t, args|
    collection = Collection.find_by!(druid: args[:collection_druid])

    File.open('export.jsonl', 'w') do |file|
      collection.works.where.not(druid: nil).find_each do |work|
        cocina_object = Sdr::Repository.find(druid: work.druid)
        work_form = WorkCocinaMapperService.to_work(cocina_object:, validate_lossless: false)
        hash = work_form.as_json
        hash['druid'] = work.druid
        hash['work_id'] = work.id
        hash['filename'] = work.work_files.first.filename
        file.puts(hash.to_json)
      end
    end

    puts 'Exported to export.jsonl'
  end
end
