require './workers/worker'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require "i18n"

class GoogleCrawlerWorker < Worker
  def initialize(arangodb, person)
    super(arangodb, person)

    @name = 'Google Crawler Worker'
    @data_name = 'google_crawler'
  end

  def job
    (0..100).step(10).each do |start_item_index|
      google_search = Nokogiri::HTML(open(URI.encode('http://www.google.com/search?q=' + @person['name'].gsub(' ', '+') + '+' + @person['location'].gsub(' ', '+') + '&start=' + start_item_index.to_s)))

      results = google_search.xpath('//div[@id="search"]/*').first

      results.xpath('.//ol/li').each do |search_entry|
        @data.push({
             title: search_entry.xpath('.//h3[@class="r"]/a').text,
             subtitle: search_entry.xpath('.//div[@class="f slp"]').text,
             description: search_entry.xpath('.//span[@class="st"]').text
         })
      end
    end
  end
end