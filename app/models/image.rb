class Image < ActiveRecord::Base
  validates :url, uniqueness: true
  validates :instagram_id, uniqueness: true

  def self.projects_first_day 
    dates = []
    Image.all.each {|image| dates.push(image.created_at)}
    return dates.min.to_i
  end

  def self.all_months_and_years
    filtered_months = []
    Image.all.each do |image|
      filtered_months << Date::MONTHNAMES[image.month.to_i] + " " + image.year
    end
    array = filtered_months & filtered_months
    return array
  end
end