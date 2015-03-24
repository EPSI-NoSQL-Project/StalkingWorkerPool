require './workers/worker'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class YoutubeCrawlerWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Youtube Crawler Worker'
  end

  def job
    @data['youtube_crawler'] = []

    youtube_uri = 'http://gdata.youtube.com/feeds/api/users/' + @person['name'] + '/uploads?v=2&format=5'
    youtube_data = Nokogiri::XML(open(youtube_uri)) 

    youtube_data.search('entry').each do |entry|

      numDislikes = 0
      numLikes = 0
      if ( entry.at('.//yt:rating') )
        numDislikes = entry.at('.//yt:rating').attribute('numDislikes')
        numLikes = entry.at('.//yt:rating').attribute('numLikes')
      end

      @data['youtube_crawler'].push({
        'author' => entry.at('author').at('name').text,
        'pseudo' => entry.at('.//media:credit').text,
        'user_id' => entry.at('author').at('.//yt:userId').text,
        'author_uri' => entry.at('author').at('uri').text,
        'title' => entry.at('title').text,
        'description' => entry.at('.//media:description').text,
        'published' => entry.at('published').text,
        'updated' => entry.at('updated').text,
        'category' => entry.at('.//media:category').text,
        'url' => entry.at('.//media:player').attribute('url'),
        'duration' => entry.at('.//media:content').attribute('duration'),
        'viewCount' => entry.at('.//yt:statistics').attribute('viewCount'),
        'favoriteCount' => entry.at('.//yt:statistics').attribute('favoriteCount'),
        'numDislikes' => numDislikes,
        'numLikes' => numLikes,
      })
    end

  end
end