require "instagram"

helpers do 

  def login?
    if session[:id].nil?
      return false
    else
      return true
    end
  end

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
      (Date.today - Date.parse(Image.first.date)).to_i + 1
    else 
      return 0 
    end
  end
end

CALLBACK_URL = "https://compstagram.fwd.wf/oauth/callback"

Instagram.configure do |config|
  config.client_id = "f44ef6405df04c0e89b87d06c1cb31cc"
  config.client_secret = "b38914e9f13344f8be4e68ff80fa82d1"
end

get '/' do
  @images = Image.where("tag = ? AND deleted != ?", true, true).order('date DESC')
  @months = Image.all_months_and_years
  erb :index
end

get '/users/logout' do
  session.clear
  redirect '/'
end

get '/users/login' do
  @login_error = false
  @user = User.new
  @message = " "
  erb :'login'
end

post '/login' do
  @user = User.find_by username: params[:username]
  if @user
    if @user[:password] == params[:password]
      session[:id] = @user[:id]
      redirect '/'
    else
      @login_error = true
      erb :'login'
    end
  else
    @user = User.new
    @login_error = true
    erb :'login'
  end
end

get '/gallery/:year-:month' do
  @images = Image.where("year = ? AND month = ? AND deleted != ?", params['year'], params['month'], true).order('day ASC')
  erb :monthgallery
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  User.create(
    instagram_id: response.user.id,
    accesstoken: response.access_token,
    username: response.user.username)
  redirect "/"
end

get "/instagram_upload" do
  if login?
    client = Instagram.client(:access_token => User.find(1).accesstoken)
    if(params['maxid'] != nil)
      data = client.user_recent_media(:max_id => params['maxid'])
    else 
      data = client.user_recent_media
    end
    maxid = data.pagination.next_max_id
    displayInstagramImages = ''
    for item in data
      image_link = item.images.low_resolution.url
      displayInstagramImages += "<div class='col-md-4 col-sm-6'><img src=#{image_link} class='img-responsive instagram-image' data-url="+item.images.standard_resolution.url+" data-thumbnail="+item.images.thumbnail.url+" data-lowres="+item.images.low_resolution.url+" data-createdtime="+item.created_time+" data-caption='"+item.caption.text+"' data-instagramid="+item.id+" data-instagramlink="+item.link+" style='margin-top:15px'></div>"
    end
    { :images => displayInstagramImages, :maxid => maxid }.to_json
  end
end

post "/instagram-save" do
  params['array'].each do |image|
    primary_img = Image.where("month = ? AND year =? AND tag = ?", Time.at(image[1]['created_time'].to_i).strftime("%m"), Time.at(image[1]['created_time'].to_i).strftime("%Y"), true)

    if(primary_img.empty?)
      tag = true
    else 
      tag = false
    end

    Image.create(
      url:            image[1]['url'],
      thumbnail:      image[1]['thumbnail'],
      lowres:         image[1]['lowres'],
      created_time:   image[1]['created_time'],
      month:          Time.at(image[1]['created_time'].to_i).strftime("%m"), 
      day:            Time.at(image[1]['created_time'].to_i).strftime("%d"),
      year:           Time.at(image[1]['created_time'].to_i).strftime("%Y"),
      date:           Time.at(image[1]['created_time'].to_i).strftime("%Y-%m-%d"),
      caption:        image[1]['caption'],
      instagram_id:   image[1]['instagram_id'],
      instagram_link: image[1]['instagram_link'],
      tag:            tag)
  end
  'success'.to_json  
end

get '/subscriptions' do 
  params["hub.challenge"]
end

post '/set_primary' do
  month = params['month'].length == 1? '0'+params['month'] : params['month']
  Image.where('month = ?', month).update_all(tag: false)
  Image.update(params['id'], tag: true)
  'success'.to_json  
end

# post '/deleteimg' do
#   id = params['id']
#   Image.update(id, deleted: true)
#   'success'.to_json  
# end

post '/updateinfo' do
  params['data'].each do |image|
    results = image[1][1].split
    month = Date::MONTHNAMES.index(results[0]).to_s
    month = month.length == 1? '0'+month : month
    day = results[1].length == 1? '0'+results[1] : results[1]
    Image.update(image[1][0], month: month, day: day)
  end
  'success'.to_json  
end

post '/subscriptions' do 
  params = JSON.parse(request.env["rack.input"].read)
  instagram_image_id = params[0]['data']['media_id']
  uri = URI.parse("https://api.instagram.com/v1/media/#{instagram_image_id}?access_token=857033525.aed2309.b38ab00be4d44c6388f7f0ec0eb3503a")
  response = Net::HTTP.get(uri)
  hash = JSON.parse(response)

  if (hash['data']['tags'].last == 'my365') 
    primary_img = Image.where("month = ? AND year =? AND tag = ?", Time.now.strftime("%m"), Time.now.strftime("%Y"), true)

    if(primary_img.empty?)
      tag = true
    else 
      tag = false
    end

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
      longitude:      hash['data']['location']['longitude'].to_s,
      tag:            tag)
  end
end

