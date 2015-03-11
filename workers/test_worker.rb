require './workers/worker'

class TestWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Test Worker'
  end

  def job
    @data = {
        'example' => 'Some info',
        'animals' => ['dog', 'cat']
    }
  end
end