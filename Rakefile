require 'rake'
require 'csv'
require "sinatra/activerecord/rake"
require ::File.expand_path('../config/environment', __FILE__)

Rake::Task["db:create"].clear
Rake::Task["db:drop"].clear

# NOTE: Assumes SQLite3 DB
desc "create the database"
task "db:create" do
  touch 'db/db.sqlite3'
end

desc "drop the database"
task "db:drop" do
  rm_f 'db/db.sqlite3'
end

desc 'Retrieves the current schema version number'
task "db:version" do
  puts "Current version: #{ActiveRecord::Migrator.current_version}"
end

desc "import data from files to database"
task :import do
    puts "Importing Images..."
    CSV.foreach("db-backup.csv", :encoding => 'windows-1251:utf-8') do |row|
        puts row
        d = Image.new(
            :id => row[0],
            :url => row[1],
            :created_time => row[2],
            :month => row[3],
            :day => row[4],
            :year => row[5],
            :caption => row[6],
            :instagram_id => row[7],
            :instagram_link => row[8],
            :latitude => row[9],
            :longitude => row[10],
            :created_at => row[11],
            :updated_at => row[12],
            :thumbnail => row[13],
            :lowres => row[14],
            :date => row[15],
            :tag => row[16]
            )
            d.save!
    end
    puts "=========== > FINISHED!"
end