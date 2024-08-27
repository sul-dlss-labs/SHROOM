# frozen_string_literal: true

desc 'Exports metadata for Works in a Collection'
task :export_csv, [:collection_druid] => :environment do |_t, args|
  collection = Collection.find_by!(druid: args[:collection_druid])

  rows = CsvService.call(works: collection.works)
  CSV.open('export.csv', 'w') do |csv|
    rows.each { |row| csv << row }
  end

  puts 'Exported to export.csv'
end
