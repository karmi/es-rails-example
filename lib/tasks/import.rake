require Rails.root.join('lib/importer')

namespace :db do
  desc "Import the records from a StackExchange XML dump"
  task :import => :environment do
    importer = StackExchange::Importer.new ENV['PATH']
    importer.import!
  end
end
