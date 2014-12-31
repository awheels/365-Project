helpers do 


  def get_year_from_date(date)
    Time.at(date).strftime("%Y").to_i
  end

  def get_month_from_date(date)
    Time.at(date).strftime("%m").to_i
  end

  def get_day_from_date(date)
    Time.at(date).strftime("%d").to_i
  end

  def total_months(date)
    if get_year_from_date(date) == get_year_from_date(Time.now)
      if get_day_from_date(Time.now) >= get_day_from_date(date)
        return get_month_from_date(Time.now) - get_month_from_date(date)
      else 
        return (get_month_from_date(Time.now) - get_month_from_date(date))-1
      end
    elsif get_month_from_date(Time.now) > get_month_from_date(date)
      return (get_year_from_date(Time.now) - get_year_from_date(date))*12 + (get_month_from_date(Time.now)-get_month_from_date(date))
    elsif get_month_from_date(Time.now) < get_month_from_date(date)
      return ((get_year_from_date(Time.now) - get_year_from_date(date))-1)*12 + (12 - get_month_from_date(date)-get_month_from_date(Time.now))
    elsif get_month_from_date(Time.now) == get_month_from_date(date)
      if get_day_from_date(Time.now) >= get_day_from_date(date)
        return (get_year_from_date(Time.now) - get_year_from_date(date))*12
      else
        return ((get_year_from_date(Time.now) - get_year_from_date(date))-1)*12
      end
    end
  end

  def total_days
    if (Image.all.length != 0)
      (Date.today - Date.parse(Image.first.date)).to_i 
    else 
      return 0 
    end
  end

  def projects_years_months_days(start_date)
    array = []
    array << total_months(start_date) / 12   #years
    array << total_months(start_date) % 12   #months
    if get_day_from_date(Time.now) > get_day_from_date(start_date) #days
      array << (get_day_from_date(Time.now) - get_day_from_date(start_date))
    elsif get_day_from_date(Time.now) < get_day_from_date(start_date)
      array << ((Date.new((Date.today).year,(Date.today).month-1,-1).mday) - get_day_from_date(start_date)) + get_day_from_date(Time.now)
    else 
      array << 0
    end
  end
end

get '/' do
  # @images = Image.where({month: Time.now.strftime("%m"), year: Time.now.strftime("%Y")})
  @images = Image.order('date DESC')
  @months = Image.all_months_and_years
  erb :index
end

get '/subscriptions' do 
  params["hub.challenge"]
end

post '/subscriptions' do 
  params = JSON.parse(request.env["rack.input"].read)
  instagram_image_id = params[0]['data']['media_id']
  uri = URI.parse("https://api.instagram.com/v1/media/#{instagram_image_id}?access_token=857033525.aed2309.b38ab00be4d44c6388f7f0ec0eb3503a")
  response = Net::HTTP.get(uri)
  hash = JSON.parse(response)

  if (hash['data']['tags'].last == 'my365') #&& (Time.now.utc.to_date == Time.at(hash['data']['created_time'].to_i).to_date)
    Image.create(
      url:            hash['data']['images']['standard_resolution']['url'],
      thumbnail:      hash['data']['images']['thumbnail']['url'],
      lowres:         hash['data']['images']['low_resolution']['url'],        
      created_time:   hash['data']['created_time'],
      month:          Time.now.strftime("%m"), 
      day:            Time.now.strftime("%d"),
      year:           Time.now.strftime("%Y"),
      date:           Date.today.to_s,
      caption:        hash['data']['caption']['text'],
      instagram_id:   hash['data']['id'],    
      instagram_link: hash['data']['link'],
      latitude:       hash['data']['location']['latitude'].to_s,
      longitude:      hash['data']['location']['longitude'].to_s)
  end
end

