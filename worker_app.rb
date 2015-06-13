require './workers/init_worker'
require './workers/google_crawler_worker'
require './workers/enjoygram_crawler_worker'
require './workers/twitter_crawler_worker'
require './workers/facebook_crawler_worker'
require './workers/youtube_crawler_worker'
require 'ashikawa-core'
require 'yell'
require 'redis'
require 'json'
require 'elasticsearch'

logger = Yell.new(STDOUT)

redis = Redis.new

arangodb = Ashikawa::Core::Database.new do |config|
  config.url = 'http://localhost:8529'
  config.logger = logger
end

elasticsearch = Elasticsearch::Client.new host: '127.0.0.1', port: 9200, log: true

Thread.abort_on_exception = true

worker_pool = Thread.new do
  while true do
    person = redis.rpop('workers')

    if person
      # Parse the JSON
      person = JSON.parse(person)

      # Run the initialization worker
      init_worker = InitWorker.new(arangodb, person)
      init_worker.run

      # Set the ArangoDB document key
      person['key'] = init_worker.person.key

      # Add workers here

      ##### GOOGLE CRAWLER ######
      google_crawler_thread = Thread.new do
        google_crawler_worker = GoogleCrawlerWorker.new(arangodb, person)
        google_crawler_worker.run
      end

      ##### TWITTER CRAWLER ######
      twitter_crawler_thread = Thread.new do
        twitter_crawler = TwitterCrawlerWorker.new(arangodb, person)
        twitter_crawler.run
      end

      ##### FACEBOOK CRAWLER ######
      # facebook_crawler_thread = Thread.new do
      #   facebook_crawler = FacebookCrawlerWorker.new(arangodb, person)
      #   facebook_crawler.run
      # end

      ##### YOUTUBE CRAWLER ######
      youtube_worker_thread = Thread.new do
        youtube_worker = YoutubeCrawlerWorker.new(arangodb, person)
        youtube_worker.run
      end

      ##### ENJOYGRAM CRAWLER ######
      enjoygram_crawler_thread = Thread.new do
        enjoygram_worker = EnjoyGramWorker.new(arangodb, person)
        enjoygram_worker.run
      end

      # Wait for crawlers
      google_crawler_thread.join
      twitter_crawler_thread.join
      # facebook_crawler_thread.join
      youtube_worker_thread.join
      enjoygram_crawler_thread.join

      # Add the tags to ElasticSearch
      keywords = arangodb.query.execute('
        LET special_chars = [ ".", "-", ",", ":", ";", "·", "\n", "(", ")" ]

        LET keywords = (
            FOR person in people
            FILTER person._key == @person_key

            LET google_data = APPEND(
              SPLIT(SUBSTITUTE(TRIM(person.data.google_crawler[*].title), special_chars, ""), " "),
              APPEND(
                SPLIT(SUBSTITUTE(TRIM(person.data.google_crawler[*].subtitle), special_chars, ""), " "),
                SPLIT(SUBSTITUTE(TRIM(person.data.google_crawler[*].description), special_chars, ""), " ")
              )
            )

            LET enjoygram_data = APPEND(
              SPLIT(SUBSTITUTE(TRIM(person.data.enjoygram_crawler[*].bio), special_chars, ""), " "),
              APPEND(
                SPLIT(SUBSTITUTE(TRIM(person.data.enjoygram_crawler[*].images[*].description), special_chars, ""), " "),
                SPLIT(SUBSTITUTE(TRIM(person.data.enjoygram_crawler[*].images[*].comments[*].comment), special_chars, ""), " ")
              )
            )

            LET twitter_data = APPEND(
              SPLIT(SUBSTITUTE(TRIM(person.data.twitter_crawler[*].users[*].description), special_chars, ""), " "),
              SPLIT(SUBSTITUTE(TRIM(person.data.twitter_crawler[*].status[*].contenu_status), special_chars, ""), " ")
            )

            RETURN APPEND(
              twitter_data,
              APPEND(google_data, enjoygram_data)
            )
        )

        FOR keyword IN keywords[0]
        COLLECT tmp_keyword = keyword INTO collected_keyword
        FILTER LENGTH(tmp_keyword) > 2
        LET score = LENGTH(collected_keyword) * LENGTH(tmp_keyword)
        SORT score DESC
        RETURN {
          "keyword": tmp_keyword,
          "occurences": LENGTH(collected_keyword),
          "score": score
        }
      ', bind_vars: { 'person_key' => person['key'] }).to_a

      # Make the tags insertable in ElasticSearch
      tags = []
      for keyword in keywords
        tags << {
            label: keyword['keyword'],
            score: keyword['score']
        }
      end

      elasticsearch.create index: 'people', type: 'person', id: person['key'],
       body: {
         name: person['name'],
         location: person['location'],
         tags: tags
       }

      puts 'Finished stalking ' + person['name'] + ' in ' + person['location'] + '.'
    end
  end
end

worker_pool.join