require './workers/init_worker'
require './workers/google_crawler_worker'
require 'ashikawa-core'
require 'yell'
require 'redis'
require 'json'

logger = Yell.new(STDOUT)

redis = Redis.new

arangodb = Ashikawa::Core::Database.new do |config|
  config.url = 'http://localhost:8529'
  config.logger = logger
end

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
      Thread.new do
        google_crawler_worker = GoogleCrawlerWorker.new(arangodb, person)
        google_crawler_worker.run
      end
    end
  end
end

worker_pool.join