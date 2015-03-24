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
    @data['google_crawler'] = []

    (0..100).step(10).each do |start_item_index|
      google_search = Nokogiri::HTML(open('http://www.google.com/search?q=' + @person['name'].gsub(' ', '+') + '+' + @person['location'].gsub(' ', '+') + '&start=' + start_item_index.to_s))

      results = google_search.xpath('//div[@id="search"]/*').first

      results.xpath('.//ol/li').each do |search_entry|
        @data['google_crawler'].push({
          title: search_entry.xpath('.//h3[@class="r"]/a').text,
          subtitle: search_entry.xpath('.//div[@class="f slp"]').text,
          description: search_entry.xpath('.//span[@class="st"]').text
        })
      end
    end
  end
end