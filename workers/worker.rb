require 'json'

class Worker
  @name
  @database
  @person
  @data

  def initialize(database, person)
    @database = database
    @person = person
  end

  def run
    puts 'Running : ' + @name + '...'

    job()

    @person = @database['stalker'].fetch(@person['key'])
    @person['data'] << @data
    @person.save
  end

  def job
    # Fill this part with the job to do
  end

  def person
    return @person
  end
end