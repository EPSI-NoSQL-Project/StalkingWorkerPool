require 'json'

class Worker
  @name
  @arangodb
  # @elasticsearch
  @person
  @relatives
  @data

  def initialize(arangodb, person)
    @arangodb = arangodb
    # @elasticsearch = elasticsearch
    @person = person
    @data = {}
    @relatives = []
  end

  def run
    puts 'Running : ' + @name + '...'

    job()
    persist()

    puts 'Finished : ' + @name + '.'
  end

  def job
    # Fill this part with the job to do
  end

  def persist
    # Persist the information about the person
    @person = @arangodb['people'].fetch(@person['key'])
    @person['data'] << @data
    @person.save

    # Persist the relatives of the person
    @relatives.each do |relative|
      relative = @arangodb['people'].create_document(relative)

      @arangodb.graph('relatives').edge_collection('relations').add(from: @person, to: relative)
    end
  end

  def person
    return @person
  end
end