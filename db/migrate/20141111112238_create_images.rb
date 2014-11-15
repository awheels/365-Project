class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :url
      t.string :created_time
      t.string :month
      t.string :day
      t.string :year
      t.string :caption
      t.string :instagram_id
      t.string :instagram_link
      t.string :latitude
      t.string :longitude
      t.timestamps
    end
  end
end
