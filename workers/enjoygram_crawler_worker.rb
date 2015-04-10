require './workers/worker'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class EnjoyGramWorker < Worker
  def initialize(arangodb, person)
    super(arangodb, person)

    @name = 'Enjoygram Crawler Worker'
  end

  def job
    @data['enjoygram_crawler'] = []

    enjoygram_search = Nokogiri::HTML(open('http://www.enjoygram.com/search/' + @person['name'].gsub(' ', '+')))

    # User search results
    results = enjoygram_search.xpath('.//div[@class="container search-page"]/div[@class="half-side right"]')

    # Crawl the user profile
    results.xpath('.//div[contains(@class, "user")]/a[@class="username"]').each do |profile_link|
      enjoygram_user_profile = Nokogiri::HTML(open('http://www.enjoygram.com' + profile_link['href']))

      enjoygram_user_details = enjoygram_user_profile.xpath('.//div[contains(@class, "user-details")]')
      enjoygram_user = {
          image: enjoygram_user_details.xpath('.//img').first['src'],
          username: enjoygram_user_details.xpath('.//div[@class="name"]/h2').text,
          bio: enjoygram_user_details.xpath('.//div[@class="bio"]/p').text,
          website: enjoygram_user_details.xpath('.//div[@class="bio"]/a').first['href'],
          images: []
      }

      # Crawl each image
      enjoygram_user_profile.xpath('.//ul[contains(@class, "items")]/li[@class="item"]/a').each do |user_image_link|
        enjoygram_image_page = Nokogiri::HTML(open('http://www.enjoygram.com' + user_image_link['href']))

        enjoygram_image_container = enjoygram_image_page.xpath('.//div[@class="media clearfix"]/div[contains(@class, "top")]')

        enjoygram_image = {
            url: enjoygram_image_container.xpath('.//div[@class="left"]/img').first['src'],
            description: enjoygram_image_container.xpath('.//div[@class="right"]//p[contains(@class, "desc")]').text,
            comments: []
        }

        # Crawl each person that liked the image
        enjoygram_image_container.xpath('.//div[@class="right"]//div[contains(@class, "likes")]/a').each do |enjoygram_liker|
          @relatives << {
              username: enjoygram_liker['href'],
              image: enjoygram_liker.xpath('.//img').first['src']
          }
        end


        # Crawl each image's comments
        enjoygram_image_container.xpath('.//div[@class="right"]//div[@class="comments-wrapper"]/div[@class="comments-box"]/div[@class="comment"]').each do |comment_container|
          enjoygram_comment = {
              username: comment_container.xpath('.//div[@class="comment-content"]/a').text,
              comment: comment_container.xpath('.//div[@class="comment-content"]/span[contains(@class, "text")]').text
          }

          @relatives << {
              username: comment_container.xpath('.//div[@class="comment-content"]/a').text,
              image: comment_container.xpath('.//a/img').first['src']
          }

          enjoygram_image[:comments].push(enjoygram_comment)
        end

        enjoygram_user[:images].push(enjoygram_image)
      end

      @data['enjoygram_crawler'].push(enjoygram_user)
    end
  end
end