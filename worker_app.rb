require './workers/init_worker'
require './workers/google_crawler_worker'
require './workers/enjoygram_crawler_worker'
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
      init_worker = InitWorker.new(arangodb, elasticsearch, person)
      init_worker.run

      # Set the ArangoDB document key
      person['key'] = init_worker.person.key

      # Add workers here

      ##### GOOGLE CRAWLER ######
      Thread.new do
        google_crawler_worker = GoogleCrawlerWorker.new(arangodb, elasticsearch, person)
        google_crawler_worker.run
      end

      ##### ENJOYGRAM CRAWLER ######
      Thread.new do
        enjoygram_worker = EnjoyGramWorker.new(arangodb, elasticsearch, person)
        enjoygram_worker.run
      end

      ##### TWITTER CRAWLER ######
      Thread.new do
        twitter_crawler_worker = TwitterCrawlerWorker.new(arangodb, elasticsearch, person)
        twitter_crawler_worker.run
      end

    end
  end
end

worker_pool.join