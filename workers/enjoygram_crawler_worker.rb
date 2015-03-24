require './workers/worker'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class EnjoyGramWorker < Worker
  def initialize(database, person)
    super(database, person)

    @name = 'Enjoygram Crawler Worker'
  end

  def job
    @data['enjoygram_crawler'] = []

    enjoygram_search = Nokogiri::HTML(open('http://www.enjoygram.com/search/' + @person['name'].gsub(' ', '+')))

    results = enjoygram_search.xpath('//div[@class="container search-page"]/div[@class="half-side right"]/*').first

    # Crawl the user profile
    results.xpath('.//div[@class="user"]/a[class="username"]').each do |profile_link|
      enjoygram_user_profile = Nokogiri::HTML(open('http://www.enjoygram.com' + profile_link.href))

      enjoygram_user = {
          image: enjoygram_user_profile.xpath('.//div[@class="user-details"]/img').src,
          username: enjoygram_user_profile.xpath('.//div[@class="user-details"]/div[@class="name"]/h2').text,
          bio: enjoygram_user_profile.xpath('.//div[@class="user-details"]/div[@class="bio"]/p').text,
          website: enjoygram_user_profile.xpath('.//div[@class="user-details"]/div[@class="bio"]/a').href,
          images: []
      }

      # Crawl each image
      enjoygram_user_profile.xpath('.//ul[@class="items"]/li[@class="item"]/a').each do |user_image_link|
        enjoygram_image_page = Nokogiri::HTML(open('http://www.enjoygram.com' + user_image_link.href))

        enjoygram_image_container = enjoygram_image_page.xpath('.//div[@class="media"]/div[@class="top"]/*')

        enjoygram_image = {
            url: enjoygram_image_container.xpath('.//div[@class="left"]/img').src,
            description: enjoygram_image_container.xpath('.//div[@class="right"]/p[@class="desc"]').text,
            comments: []
        }

        enjoygram_image_container.xpath('.//div[@class="right"]/div[@class="comments-wrapper"]/div[@class="comments-box"]/div[@class="comment"]').each do |comment_container|
          enjoygram_comment = {
              username: comment_container.xpath('.//div[@class="comment-content"]/a').text,
              comment: comment_container.xpath('.//div[@class="comment-content"]/span[@class="text"]').text
          }

          enjoygram_image['comments'].push(enjoygram_comment)
        end

        enjoygram_user['images'].push(enjoygram_image)
      end

      @data['enjoygram_crawler'].push(enjoygram_user)
    end
  end
end