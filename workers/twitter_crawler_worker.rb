require './workers/worker'
require 'rubygems'
require 'json'
require 'open-uri'

class TwitterCrawlerWorker < Worker

  def initialize(database,elasticsearch, person)
  super(database,elasticsearch, person)

  @name = 'Twitter Crawler Worker'
  end

  def prepare_access_token(oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new("L9c1lqUrWOlYepeaGktLDL1lj", "gXsqcDi1iP7RtMXY6LOmqTwGgQQeDvR15jzdhOaWoSDNGb9Y81", { :site => "https://api.twitter.com", :scheme => :header })

    # now create the access token object from passed values
    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )

    return access_token
  end

  def job
  # Exchange our oauth_token and oauth_token secret for the AccessToken instance.
  access_token = prepare_access_token('871418562-LKbfKqXtfE7bVyDGb0tIowKf4nV4WnLeYCBgLSav','1kFqyPSF5FKIN2ITBxUHNpdKaw5C59LWD2C3OXf1uaL35')

  @data['twitter_crawler'] = []

  #crawl user profil
  twitter_search_profile = access_token.request(:get,'https://api.twitter.com/1.1/users/search.json?q='+ @person['name'])
  twitter_user_profile = JSON.parse(twitter_search_profile.body)[0]

  twitter_user = {
      surnom: twitter_user_profile['name'],
      description: twitter_user_profile['description'],
      lien_image_profile: twitter_user_profile['profile_image_url'],
      amis:[]
  }

  #crawl friendlist user profil
  twitter_search_friendlist = access_token.request(:get, 'https://api.twitter.com/1.1/friends/list.json?screen_name=' + @person['name'] + '&include_user_entities=false&skip_status=true')
  twitter_user_profile_friendlist = JSON.parse(twitter_search_friendlist.body)

  twitter_user_friendlist = {
    utilisateurs: twitter_user_profile_friendlist['users']
  }

  twitter_user[:amis].push(twitter_user_friendlist)

  @data['twitter_crawler'].push(twitter_user)

  end

end




