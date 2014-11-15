Sinatra
=============

Brought to you by Lighthouse Labs

## Getting Started

1. `bundle install`
2. `shotgun -p 3000 -o 0.0.0.0`
3. Visit `http://localhost:3000/` in your browser


Time.at(1415679640).to_date === Date.today

#setting authorization
curl -F 'client_id=f44ef6405df04c0e89b87d06c1cb31cc' -F 'client_secret=b38914e9f13344f8be4e68ff80fa82d1' -F 'grant_type=authorization_code' -F 'redirect_uri=http://compstagram.fwd.wf/oauth/callback' -F 'code=59a329f21f664a74a3e24e73dfd57551' https://api.instagram.com/oauth/access_token

{"access_token":"857033525.f44ef64.eb596e8988d84c8a934edb27c0d52ded","user":{"username":"and_wheeler","bio":"","website":"","profile_picture":"http:\/\/images.ak.instagram.com\/profiles\/profile_857033525_75sq_1388003121.jpg","full_name":"Andrew Wheeler","id":"857033525"}}

#setting subscription
curl -F 'client_id=f44ef6405df04c0e89b87d06c1cb31cc' -F 'client_secret=b38914e9f13344f8be80fa82d1' -F 'object=user' -F 'aspect=media' -F'verify_token=857033525.f44ef64.eb596e8988d84c8a934edb27c0d52ded'  -F 'callback_url=http://compstagram.fwd.wf/subscriptions' https://api.instagram.com/v1/subscriptions/

{"meta":{"code":200},"data":{"object":"user","object_id":null,"aspect":"media","callback_url":"http:\/\/compstagram.fwd.wf\/subscriptions","type":"subscription","id":"14337025"}}


   

    hash['data'].each do |content|
      if content['tags'].include?(gallery.tag)
        Image.create(
          url:            content['images']['standard_resolution']['url'],
          gallery_id:     gallery.id,
          instagram_id:   content['id'],     #TODO check that this is the right id
          user_id:        user.id)
      end