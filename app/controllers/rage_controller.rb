class RageController < ApplicationController

  # Gets the most recent tweet by RageCurator
  def home
    require 'open-uri'
    require 'json'
    url = 'https://api.twitter.com/1/statuses/user_timeline.json?screen_name=ragecurator&count=1&trim_user=true'
    content = JSON.parse(open(url).read)[0]["text"]
    @text = content[0, content.index("http")]
    @image = content[content.index("http"), content.length] 
  end

  def add
    #@add_comics = []
    #Comic.where(:view => false).limit(25).each do | c |
      #@add_comics.push c
    #end
    @add_comics = Comic.where(:view => false).limit(25)
    if @add_comics.nil?
      @first_comic_id = @add_comics.first[:id]
      @last_comic_id = @add_comics.last[:id]
    end

  end

  def queue
  end

  # Scrapes reddit.com
  def scrape
    require 'open-uri'
    require 'nokogiri'

    @scraped_comics = []
    @add_count = 0

    url = 'http://www.reddit.com/r/fffffffuuuuuuuuuuuu'
    doc = Nokogiri::HTML(open(url))

    doc.xpath('//a[@class="title "]').each do | method_span |  
      @scraped_comics.push [method_span.content, method_span["href"]]
    end  

    doc.xpath('//a[@class="comments"]').each_with_index do | method_span, i |  
      @scraped_comics[i].push method_span["href"]
    end

    @scraped_comics.each do | scrape |
      if Comic.where(:reddit => scrape[2]).empty?
        Comic.create( :title => scrape[0], :link => scrape[1], :reddit => scrape[2], 
                      :view => false, :tweet => false)
        @add_count += 1
      end
    end
    
  end

  def add_submit

    puts "=============================>"
    puts params[:first_comic_id]
    puts "=============================>"

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
    # For all in add_comic modify title and link in db, mark as tweet.
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
        c.tweet = true
        c.save
      end
    end
     
  end

  def is_i?(str)
    !!(str =~ /^[-+]?[0-9]+$/)
  end

  def image?(str)
    !FastImage.type(str).nil?
  end
end
