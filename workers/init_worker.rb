require './workers/worker'

class InitWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Initialization Worker'
  end

  def job
    # Create the base empty person
    @person = @database['stalker'].create_document({
      name: @person['name'],
      data: []
    })
  end

  def persist
    # Bypass the persistance
  end
end