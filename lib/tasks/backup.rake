require 'database_dumper'

namespace :backup do
  desc "Dumps an unencrypted view of the database to CSVs"
  task :export => :environment do
    DatabaseDumper.export_all_csvs
  end

  desc "Loads the database from CSVs"
  task :import => :environment do
    DatabaseDumper.import_all_csvs
  end

  desc "Removes the CSV files (run after done with files)"
  task :cleanup => :environment do
    DatabaseDumper.cleanup
  end
end
