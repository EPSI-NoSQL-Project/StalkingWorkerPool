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
    puts @person['name']

    #youtube_uri = 'http://gdata.youtube.com/feeds/api/users/' + @person['name'] + '/uploads?v=2&format=5&max-results=5'
    youtube_uri = 'http://gdata.youtube.com/feeds/api/users/' + @person['name'] + '/uploads?v=2&format=5'
    youtube_data = Nokogiri::XML(open(youtube_uri)) 

    youtube_data.search('entry').each do |entry|
      
      puts entry.at('author').at('name').text
      puts entry.at('author').at('uri').text
      puts entry.at('author').at('.//yt:userId').text
      puts entry.at('title').text
      puts entry.at('.//media:description').text
      puts entry.at('published').text
      puts entry.at('updated').text
      puts entry.at('.//media:category').text
      puts entry.at('.//media:credit').text
      puts entry.at('.//media:player').attribute('url')
      puts entry.at('.//media:content').attribute('duration')

      puts entry.at('.//yt:statistics').attribute('viewCount')
      puts entry.at('.//yt:statistics').attribute('favoriteCount')
      if ( entry.at('.//yt:rating') )
        puts entry.at('.//yt:rating').attribute('numDislikes')
        puts entry.at('.//yt:rating').attribute('numLikes')
      else
        puts "0"
        puts "0"
      end
    end

  end
end