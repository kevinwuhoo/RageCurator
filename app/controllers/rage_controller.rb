require 'open-uri'
require 'json'


class RageController < ApplicationController
  before_filter :authenticate, :except => [:home]

  def tweet

    @comic = Comic.where(:queue => true).order("updated_at DESC").limit(1)[0]

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
      
      # If gif, doin't tweet with pic.twitter
      if comic_path[-3..-1] == "gif"
        client.update("#{@comic.title} #{@comic.link}")
      else
        client.update_with_media("#{@comic.title} #{@comic.link}", File.new(comic_path))
      end

      @comic.queue = false
      @comic.tweet = true
      @comic.save
      
    else
      @comic = nil #mark so that tweet view knows if successful
    end
  end

  # Gets the most recent tweet by RageCurator from twitter
  def home
    @comic = Comic.where(:tweet => true).order("updated_at DESC").limit(1)[0]

  end

  def add
    @add_comics = Comic.where(:view => false).limit(25)
    @add_count = Comic.where(:view => false).length
  end

  def queue
    @queue_comics = Comic.where(:queue => true)
    @queue_count = Comic.where(:queue => true).length
  end

  def scrape

    @total_ctr = 0
    @duplicates = 0
    @added_comics = []

    rage_subreddits = %w[
      http://www.reddit.com/r/fffffffuuuuuuuuuuuu
      http://www.reddit.com/r/classicrage
    ]

    rage_subreddits.each do |subreddit|  
      subreddit = JSON(open(subreddit + ".json").read())
      subreddit['data']['children'].each do |item|

        item = item['data']

        @total_ctr += 1
        url = nil

        # Duplicate detection using reddit link
        item['permalink'] = "http://reddit.com" + item['permalink']
        if !Comic.find_by_reddit(item['permalink']).nil?
          @duplicates += 1
          next
        end

        # Check if link is image
        if image?(item['url'])
          url = item['url']
        # If not use regex get image
        elsif item['url'].include?("imgur")
          page = open(item['url']).read()
          page =~ /<link rel="image_src" href="(.*)" \/>/
          url = $1
        end

        if !url.nil? 
          c = Comic.create(:title => item['title'], 
                           :link => url, 
                           :reddit => item['permalink'], 
                           :view => false, 
                           :tweet => false,
                           :queue => false)
          @added_comics << c
        end
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
        c.view = false
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
