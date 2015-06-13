require './workers/worker'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class YoutubeCrawlerWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Youtube Crawler Worker'
    @data_name = 'youtube_crawler'
  end


  def job
    # Get 'userPseudo' => 'uri'
    userToFind = cleanSpaceChar(@person['name'])
    usersURI = findUserURIList(userToFind)
    # Find videos list from the URI
	findUserVideo(usersURI)
  end

  def findUserURIList(userToFind)
	usersURI = {}

    youtubeUsers_uri = 'https://gdata.youtube.com/feeds/api/videos?q=%22'+ userToFind +'%22'
	puts 'URI : '+youtubeUsers_uri

	youtubeUsers_data = Nokogiri::XML(open(youtubeUsers_uri)) 
	youtubeUsers_data.search('entry').each do |entry|
		userPseudo = entry.at('author').at('name').text
		userURI = entry.at('author').at('uri').text
		usersURI[userPseudo] = userURI
	end

	return usersURI
  end

  def findUserVideo(usersURI)
  	usersURI.each do |userKey|
		youtube_uri = userKey[1] + '/uploads?v=2&format=5'
	    youtube_data = Nokogiri::XML(open(youtube_uri)) 

	    youtube_data.search('entry').each do |entry|
	    	videoAuthor = entry.at('author').at('name').text

	    	# We only keep the video if the author has got the same name as the input one
	    	if @person['name'].upcase == videoAuthor.upcase
	    		puts videoAuthor.upcase+ " = " +entry.at('title').text

	    		addVideo(entry)
	    	end
	    end
	end
  end

  def addVideo(entry)
  	numDislikes = 0
	numLikes = 0
	if ( entry.at('.//yt:rating') )
		numDislikes = entry.at('.//yt:rating').attribute('numDislikes')
		numLikes = entry.at('.//yt:rating').attribute('numLikes')
	end

	viewCount = 0
	favoriteCount = 0
	if ( entry.at('.//yt:statistics') )
		viewCount = entry.at('.//yt:statistics').attribute('viewCount')
		favoriteCount = entry.at('.//yt:statistics').attribute('favoriteCount')
	end

	@data.push({
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
		'viewCount' => viewCount,
		'favoriteCount' => favoriteCount,
		'numDislikes' => numDislikes,
		'numLikes' => numLikes,
	})
  end

  def cleanSpaceChar(myString)
  	return myString.gsub(" ", "+")
  end
end