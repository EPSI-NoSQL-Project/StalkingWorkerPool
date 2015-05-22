require './workers/worker'
require 'rubygems'
require 'pp'
require 'fb_graph'
require 'koala'
require 'pp'

class FacebookCrawlerWorker < Worker

  def initialize(arangodb, person)
    super(arangodb, person)

    @name = 'Facebook Crawler Worker'
    @data_name = 'facebook_crawler'
  end

  def job

  @graph = Koala::Facebook::API.new

    person = @person['name']
    pp facebook_search_profile = @graph.get_objects(person)

   facebook_search_profile.each do |user|
      facebook_users = {
          nom: user['name'],
          lien: user['link'],
          picture: user['picture']
      }
      @data.push(facebook_users)
   end

  end

end