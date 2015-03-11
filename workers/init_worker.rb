require './workers/worker'

class InitWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Initialization Worker'
  end

  def run
    puts 'Running : ' + @name + '...'

    job()
  end

  def job
    # Create the base empty person
    @person = @database['stalker'].create_document({
      name: @person['name'],
      data: []
    })
  end
end