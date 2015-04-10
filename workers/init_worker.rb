require './workers/worker'

class InitWorker < Worker
  def initialize(arangodb, person)
    super(arangodb, person)

    @name = 'Initialization Worker'
  end

  def job
    # Create the base empty person
    @person = @arangodb['people'].create_document({
      name: @person['name'],
      location: @person['location'],
      data: []
    })

    # @elasticsearch.index index: 'people', type: 'person', id: @person.key,
    #   body: {
    #     name: @person['name'],
    #     location: @person['location'],
    #     tags: []
    #   }
  end

  def persist
    # Bypass the persistance
  end
end