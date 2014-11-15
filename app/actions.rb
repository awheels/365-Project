

get '/' do
  @images = Image.all
  erb :index
end

get '/subscriptions' do 
  params["hub.challenge"]
end

post '/subscriptions' do 
  params = JSON.parse(request.env["rack.input"].read)
  instagram_image_id = params[0]['data']['media_id']
  uri = URI.parse("https://api.instagram.com/v1/media/#{instagram_image_id}?access_token=857033525.f44ef64.eb596e8988d84c8a934edb27c0d52ded")
  response = Net::HTTP.get(uri)
  hash = JSON.parse(response)

  if (hash['data']['tags'].last == 'my365') #&& (Time.now.utc.to_date == Time.at(hash['data']['created_time'].to_i).to_date)
    Image.create(
      url:            hash['data']['images']['standard_resolution']['url'],
      created_time:   hash['data']['created_time'],
      month:          Time.now.strftime("%m"), 
      day:            Time.now.strftime("%d"),
      year:           Time.now.strftime("%Y"),
      caption:        hash['data']['caption']['text'],
      instagram_id:   hash['data']['id'],    
      instagram_link: hash['data']['link'],
      latitude:       hash['data']['location']['latitude'].to_s,
      longitude:      hash['data']['location']['longitude'].to_s)
  end
end

