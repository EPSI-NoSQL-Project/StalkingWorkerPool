require './workers/worker'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'i18n'

class YoutubeCrawlerWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Youtube Crawler Worker'
    @data_name = 'youtube_crawler'
  end


  def job
    # Get 'userPseudo' => 'uri'
    userToFind = cleanSpaceChar(@person['name'])
    usersChannelID = finduserChannelIDList(userToFind)
    # Find videos list from the URI
    findVideosChannel(usersChannelID)
  end

  def finduserChannelIDList(userToFind)
    usersChannelID = {}

    youtubeFindUserURI = 'https://www.googleapis.com/youtube/v3/search?part=snippet&order=viewCount'
    youtubeFindUserURI << '&key=AIzaSyDeLLInjziwLJiJdWpMWHm_uYjSlKcWARg'
    youtubeFindUserURI << '&type=video'
    youtubeFindUserURI << '&maxResults=50'
    youtubeFindUserURI << '&q=' << userToFind
    puts 'YOUTUBE URI - find : ' << youtubeFindUserURI

    youtubeChannelsTML = Nokogiri::HTML(open(youtubeFindUserURI)) 
    youtubeChannels = JSON.parse(youtubeChannelsTML)

    youtubeChannels['items'].each do |entry|
      channelId = entry['snippet']['channelId']
      usersChannelID[channelId] = channelId
    end

    return usersChannelID
  end

  def findVideosChannel(usersChannelID)
    usersChannelID.each do |channelID|
      youtubeFindChannelURI = 'https://www.googleapis.com/youtube/v3/search?part=snippet'
      youtubeFindChannelURI << '&key=AIzaSyDeLLInjziwLJiJdWpMWHm_uYjSlKcWARg'
      youtubeFindChannelURI << '&order=date'
      youtubeFindChannelURI << '&maxResults=50' 
      youtubeFindChannelURI << '&channelId='  << channelID[0]
      puts 'YOUTUBE - channel ' << youtubeFindChannelURI

      youtubeVideosHTML = Nokogiri::HTML(open(youtubeFindChannelURI)) 
      youtubeVideos = JSON.parse(youtubeVideosHTML)

      youtubeVideos['items'].each do |entry|
        unless entry['id']['videoId'].nil?

          link = 'https://www.youtube.com/watch?v=' << entry['id']['videoId']
          preview = entry['snippet']['thumbnails']['default']['url']

          @data.push({
            'videoId' => entry['id']['videoId'],
            'titre' => entry['snippet']['title'],
            'description' => I18n.transliterate(entry['snippet']['description']),
            'link' => link,
            'publishedAt' => entry['snippet']['publishedAt'],
            'preview' => preview,
            'channelId' => entry['snippet']['channelId'],
            'channelTitle' => entry['snippet']['channelTitle']
          })
        end 
      end
    end
  end

  def cleanSpaceChar(myString)
   return myString.gsub(" ", "+")
  end
end