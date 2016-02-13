require 'ansi'

require Rails.root.join('lib/importer')
require Rails.root.join('lib/index_manager')

namespace :db do
  desc "Import the records from a StackExchange XML dump"
  task :import => :environment do
    importer = StackExchange::Importer.new ENV['PATH']
    importer.import!
  end
end

namespace :elasticsearch do
  desc "Import the records from the database into Elasticsearch"
  task :import => :environment do
    StackExchange::IndexManager.create_index force: ENV.fetch('FORCE', false)

    errors = StackExchange::IndexManager.import

    if errors.blank?
      STDERR.puts "Records imported successfully into Elasticsearch".ansi(:green)
    else
      STDERR.puts "[!] There were errors during the import into Elasticsearch:".ansi(:red)
      errors.each { |e| STDERR.puts e }
    end
  end
end
