require './workers/init_worker'
require './workers/youtube_crawler_worker'
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

person = {'name' => 'k2r79'}

# Run the initialization worker
init_worker = InitWorker.new(arangodb, person)
init_worker.run

person['key'] = init_worker.person.key

youtube_crawler_worker = YoutubeCrawlerWorker.new(arangodb, person)
youtube_crawler_worker.run
