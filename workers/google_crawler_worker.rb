require './workers/worker'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class GoogleCrawlerWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Google Crawler Worker'
  end

  def job
    google_search = Nokogiri::HTML(open('http://www.google.com/search?q=' + @person['name'].gsub(' ', '+')))

    results = google_search.xpath('//div[@id="search"]/*').first

    @data['google_crawler'] = []
    results.xpath('.//ol/li').each do |search_entry|
      @data['google_crawler'].push({
        title: search_entry.xpath('.//h3[@class="r"]/a').text,
        subtitle: search_entry.xpath('.//div[@class="f slp"]').text,
        description: search_entry.xpath('.//span[@class="st"]').text
      })
    end
  end
end