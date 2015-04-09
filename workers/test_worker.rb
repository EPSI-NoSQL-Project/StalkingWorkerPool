require './workers/worker'

class TestWorker < Worker
  def initialize(database, elasticsearch, person)
    super(database, elasticsearch, person)

    @name = 'Test Worker'
  end

  def job
    @data = {
        'example' => 'Some info',
        'animals' => ['dog', 'cat']
    }
  end
end