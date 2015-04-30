require './workers/worker'
require 'rubygems'
require 'json'
require 'open-uri'
require 'oauth'
require 'pp'

class TwitterCrawlerWorker < Worker

  def initialize(database, person)
    super(database, person)

    @name = 'Twitter Crawler Worker'
    @data_name = 'twitter_crawler'

  end

  def prepare_access_token(oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new("L9c1lqUrWOlYepeaGktLDL1lj", "gXsqcDi1iP7RtMXY6LOmqTwGgQQeDvR15jzdhOaWoSDNGb9Y81", {:site => "https://api.twitter.com", :scheme => :header})

    # now create the access token object from passed values
    token_hash = {:oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret}
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

    return access_token
  end

  def job
    access_token = prepare_access_token('871418562-LKbfKqXtfE7bVyDGb0tIowKf4nV4WnLeYCBgLSav', '1kFqyPSF5FKIN2ITBxUHNpdKaw5C59LWD2C3OXf1uaL35')

    twitter_profile = {
        users: [],
        amis: [],
        status: []
    }

    #crawl user profil
    twitter_search_profile = access_token.request(:get, URI.escape('https://api.twitter.com/1.1/users/search.json?q=' + @person['name'].gsub(' ', '+')))
    twitter_user_profile = JSON.parse(twitter_search_profile.body)

    twitter_user_profile.each do |user|
      twitter_users = {
          nom: user['name'],
          surnom: user['screen_name'],
          description: user['description'],
          lien_image_profile: user['profile_image_url']
      }
      twitter_profile[:users].push(twitter_users)
    end

    #crawl friendlist user profil
    twitter_search_friendlist = access_token.request(:get, URI.escape('https://api.twitter.com/1.1/friends/list.json?screen_name=' + @person['name'].gsub(' ', '+') + '&include_user_entities=false&skip_status=true&cursor=-50&count=200'))
    twitter_user_profile_friendlist = JSON.parse(twitter_search_friendlist.body)

    twitter_user_profile_friendlist['users'].each do |friend|
      twitter_friendlist = {
          nom: friend['name'],
          pseudo: friend['screen_name'],
          description: friend['description'],
          statuses_count: friend['statuses_count'],
          friends_count: friend['friends_count']
      }
      twitter_profile[:amis].push(twitter_friendlist)
    end


    #crawl status user profil
    twitter_search_status = access_token.request(:get, URI.escape('https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=' + @person['name'].gsub(' ', '+') +'&include_user_entities=false&skip_status=true&count=200'))
    twitter_user_profile_status = JSON.parse(twitter_search_status.body)

    twitter_user_profile_status.each do |status|
      twitter_status = {
          creation_status: status['created_at'],
          contenu_status: status['text'],
          source_status: status['source'],
          retweet: status['retweet_count'],
          time_zone: status['user']['time_zone'],
          profile_image_url_https: status['user']['profile_image_url_https']
      }
      twitter_profile[:status].push(twitter_status)
    end

    @data.push(twitter_profile)

  end
end




