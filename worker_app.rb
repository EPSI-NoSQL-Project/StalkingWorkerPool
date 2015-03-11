require './workers/init_worker'
require './workers/test_worker'
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
      ##### EXAMPLE ######
      Thread.new do
        test_worker = TestWorker.new(arangodb, person)
        test_worker.run
      end
      ##### END EXAMPLE ######
    end
  end
end

worker_pool.join