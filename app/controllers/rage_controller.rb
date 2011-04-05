class RageController < ApplicationController
  before_filter :authenticate, :except => [:home]

  def tweet
    @comic = Comic.where(:queue => true).limit(1)
    if !@comic.empty?
      @comic = @comic[0]
      @comic.queue = false
      @comic.tweet = true
      @comic.save

      Twitter.configure do |config|
        config.consumer_key       = ENV["rage_curator_consumer_key"]
        config.consumer_secret    = ENV['rage_curator_consumer_secret']
        config.oauth_token        = ENV['rage_curator_oauth_token']
        config.oauth_token_secret = ENV['rage_curator_oauth_token_secret']
      end
      client = Twitter::Client.new
      client.update("#{@comic.title} #{@comic.link}")
      
    else
      @comic = nil #tweet view determines if it displays via nil
    end
  end

  # Gets the most recent tweet by RageCurator from twitter
  def home
    require 'open-uri'
    
    url = 'https://api.twitter.com/1/statuses/user_timeline.json?screen_name=ragecurator&count=1&trim_user=true'
    content = JSON.parse(open(url).read)[0]["text"]
    @comic = Comic.new(:title => content[0, content.index("http")],
                       :link => content[content.index("http"), content.length])

  end

  def add
    @add_comics = Comic.where(:view => false).limit(25)
    if !@add_comics.empty?
      @first_comic_id = @add_comics.first[:id]
      @last_comic_id = @add_comics.last[:id]
    end

  end

  def queue
    @queue_comics = Comic.where(:queue => true).limit(10)
  end

  # Scrapes reddit.com
  def scrape
    require 'open-uri'

    @scraped_comics = []
    @add_count = 0

    url = 'http://www.reddit.com/r/fffffffuuuuuuuuuuuu'
    doc = Nokogiri::HTML(open(url))

    # Get title and link
    doc.xpath('//a[@class="title "]').each do | method_span |  
      @scraped_comics.push [method_span.content, method_span["href"]]
    end  

    # Get reddit thread
    doc.xpath('//a[@class="comments"]').each_with_index do | method_span, i |  
      @scraped_comics[i].push method_span["href"]
    end

    @scraped_comics.each do | scrape |
      if Comic.where(:reddit => scrape[2]).empty?
        Comic.create( :title => scrape[0], :link => scrape[1], 
                      :reddit => scrape[2], :view => false, :tweet => false,
                       :queue => false)
        @add_count += 1
      end
    end
    
  end

  def add_submit
    @add_comics = []
    @error = nil

    # Go through checked comics. If the link is not an image
    # display pass error otherwise add to array.
    params.each do |key, value|
      if is_i? key
        #puts "#{key} => #{value}"
        c = Comic.find_by_id key
        if !image?(params["#{key}_link"])
          @error = "#{c.title} does not have image link!"
        else
          @add_comics.push c
        end
      end
    end

    # Mark all viewed as seen.
    # For all in add_comic modify title and link in db, mark as in queue.
    if @error.nil?
      for i in (params[:first_comic_id].to_i..params[:last_comic_id].to_i)
        c = Comic.find_by_id(i)
        c.view = true
        c.save
      end
      @add_comics.each do |c|
        key = c[:id]
        c.title = params["#{key}_title"]
        c.link = params["#{key}_link"]
        c.queue = true
        c.save
      end
    end
     
  end

  def is_i?(str)
    str =~ /^[-+]?[0-9]+$/
  end

  def image?(str)
    str =~ /http:\/\/.*\.((png)|(jpg)|(bmp)|(gif))/
  end

end
