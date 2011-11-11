require 'open-uri'
class RageController < ApplicationController
  before_filter :authenticate, :except => [:home]

  def tweet
    @comic = Comic.where(:queue => true).first
    if !@comic.nil?

      Twitter.configure do |config|
        config.consumer_key       = ENV["rage_curator_consumer_key"]
        config.consumer_secret    = ENV['rage_curator_consumer_secret']
        config.oauth_token        = ENV['rage_curator_oauth_token']
        config.oauth_token_secret = ENV['rage_curator_oauth_token_secret']
      end
      client = Twitter::Client.new
      # client.update("#{@comic.title} #{@comic.link}")
      
      comic_file = @comic.link.split("/")[-1]
      # If on heroku
      if defined? Rails.root
        comic_path = "#{Rails.root}/tmp/#{comic_file}"
      else 
        comic_path = comic_file
      end
      File.open(comic_path, 'wb+') do |output|
      # Download image
        open(@comic.link) do |input|
          output << input.read
        end
      end 

      client.update_with_media("#{@comic.title}", File.new(comic_path))

      @comic.queue = false
      @comic.tweet = true
      @comic.save
      
    else
      @comic = nil #mark so that tweet view knows if successful
    end
  end

  # Gets the most recent tweet by RageCurator from twitter
  def home
    url = 'https://api.twitter.com/1/statuses/user_timeline.json?screen_name=ragecurator&count=1&trim_user=true'
    content = JSON.parse(open(url).read)[0]["text"]
    @comic = Comic.new(:title => content[0, content.index("http")],
                       :link => content[content.index("http"), content.length])

  end

  def add
    @add_comics = Comic.where(:view => false).limit(25)
    @add_count = Comic.where(:view => false).length
  end

  def queue
    @queue_comics = Comic.where(:queue => true).limit(10)
    @queue_count = Comic.where(:queue => true).length
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

    # Adds comics. Checks if reddit link is in array, if not create new row.
    @scraped_comics.each do | scrape |
      
      #puts "==========================="
      #p scrape
      #puts "==========================="

      # if Comic.where(:reddit => scrape[2]).empty?
        
      # If link is imgur and not image, get image link
      if !image?(scrape[1]) and scrape[1].include? "imgur"
        # Gets the image link with no params
        if scrape[1].include? "?"
          scrape[1] = scrape[1][0,scrape[1].index("?")]
        end
        # Open imgur link and get the image, reassign to link
        doc = Nokogiri::HTML(open(scrape[1]))
        
        scrape[1] = doc.at_xpath('//div[@class="image textbox "]').children[0].attributes["src"].to_s  
      end
    
      #puts "==========================="
      #p scrape
      #puts "==========================="

      if Comic.where(:link=> scrape[1]).empty?
        Comic.create( :title => scrape[0], :link => scrape[1], 
                      :reddit => scrape[2], :view => false, :tweet => false,
                       :queue => false)
        @add_count += 1
      end
    end
    
  end

  def add_submit
    @add_comics = []     # All selected comics
    @all_comics = []     # All comics (viewed on page)
    @error = nil


    params.each do |key, value|
      # If int key, then is marked comic, check for img link or error
      if is_i? key
        @c = Comic.find_by_id key
        if !image?(params["#{key}_link"])
          @error = "#{@c.title} does not have image link!"
        else
          @add_comics.push @c
        end
      end
      # Get all viewed comics
      # If key has title in it, add to all array
      if key =~ /\d+_title/
        #p key 
        key = key.split('_')[0]
        @all_comics.push Comic.find_by_id key
      end
    end

    if @error.nil?
      # Mark all on page as viewed
      @all_comics.each do |c|
       c.view = true
       c.save
      end
      
      # Save modified title and link and mark as queued
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
