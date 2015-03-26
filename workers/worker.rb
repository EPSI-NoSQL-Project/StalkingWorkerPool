require 'json'

class Worker
  @name
  @database
  @person
  @relatives
  @data

  def initialize(database, person)
    @database = database
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
    @person = @database['people'].fetch(@person['key'])
    @person['data'] << @data
    @person.save

    # Persist the relatives of the person
    @relatives.each do |relative|
      relative = @database['people'].create_document(relative)

      @database.graph('relatives').edge_collection('relations').add(from: @person, to: relative)
    end
  end

  def person
    return @person
  end
end