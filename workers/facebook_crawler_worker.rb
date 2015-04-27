require './workers/worker'
require 'rubygems'
require 'fb_graph'
require 'pp'
require 'oauth'
require 'koala'

class FacebookCrawlerWorker < Worker
  def initialize(arangodb, person)
    super(arangodb, person)

    @name = 'Facebook Crawler Worker'
  end

  def job
    @data['facebook_crawler'] = []
    oauth_access_token = "CAACEdEose0cBABIgkQyf2H6sAGZCXyyPA8zibTdUsSm8wlP8x9sYlgxLBhVAJsM8MCrdd5dgkjGXaWAKzgu5godszd2WjqeLigjl1XBxNALcBeijtmy3jAyJl1BRqPI0DwCP2B81qhZAZBlSiiZCw4ob7SBQKhCM4ZA3tsdzi2ccfDLsjBQVUMV4HgsPZCstq4vyWqCGefaTsKfNY94l5G"

  users = FbGraph::User.search( @person['name'],:access_token => oauth_access_token)

  @graph = Koala::Facebook::API.new(oauth_access_token)
  users.each do |user|
    facebook_user = {
      user_name: user.name,
      user_page:[]
    }

  pages = FbGraph::Page.search(@person['name'],:access_token => oauth_access_token)

   pages.each do |page|
     facebook_page = {
      category: page.category,
      nom: page.name,
      # description: page.description,
      phone: page.phone,
      username: page.username,
      photos: []
    }

    page_id = page.link.split("https://www.facebook.com/")[1]
    photos = @graph.get_connections(page_id, "photos")

    photos.each do |photo|
      facebook_photos = {
        picture: photo['picture'],
        category: photo['from']['category'],
        photo_from: photo['from']['name'],
        created_at: photo['created_time']
      }

      # photo['likes']['data'].each do |liker|
      #     liker['name']
      # end
      facebook_page[:photos].push(facebook_photos)
    end

     facebook_user[:user_page].push(facebook_page)

   end

    @data['facebook_crawler'].push(facebook_user)

  end
    end

end

