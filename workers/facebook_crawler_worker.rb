require 'fb_graph'
require 'pp'
require 'oauth'
require 'koala'

oauth_access_token = "CAACEdEose0cBAIbiRP5qQdyRvRJRx7r6ZC8ZCGsWWHJXqBCv2zuZBYcYsUHzhtU2lx6ZCBCC2fLJQJsqtwvVkJLtjbKqWj7qaU58UrZCvSk2ZBZCdthWlsyh5zDuALfiPWwCgCcZCf5v2ZAlUXJsfeiw1LckzZBbmQEuZAXFkzYZAWFxGOdPkD1f68zqbqgUkUSjvO0ePdy5GK8eUTjvdUgZCehwDjh5iZByQMzZBYZD"

users = FbGraph::User.search('Vermersch',:access_token => oauth_access_token)
pages = FbGraph::Page.search('Vermersch',:access_token => oauth_access_token)

@graph = Koala::Facebook::API.new(oauth_access_token)

users.each do |user|
  facebook_user = {
    user_name: user.name,
    user_page:[]
  }
  user_id = user.endpoint.split("https://graph.facebook.com/")[1]
  feed = @graph.get_connections(user_id, "")

end

pages.each do |page|
  facebook_page = {
    category: page.category,
    nom: page.name,
    description: page.description,
    phone: page.phone,
    username: page.username,
    photos: []
  }

  page_id = page.link.split("https://www.facebook.com/")[1]
  photos = @graph.get_connections(page_id, "photos")

  photos.each do |photo|
    facebook_photos = {
      picture: photo.picture,
      category: photo['from']['category'],
      photo_from: photo['from']['name'],
      created_at: photo.created_time

      # pp photo['likes']['data']
        # .each do |liker|
        # pp likes: liker['name']
      # end
    }
  end

end



