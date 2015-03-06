require './workers/worker'

worker_queue = Queue.new

worker_queue << Worker.new

worker_pool = Thread.new do
  while true do
    if worker_queue.size > 0
      worker = worker_queue.pop
      worker.run
    end
  end
end

worker_pool.join