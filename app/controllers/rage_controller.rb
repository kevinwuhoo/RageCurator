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
        Comic.create( :title => scrape[0], :image => scrape[1], :reddit => scrape[2], 
                      :view => false, :tweet => false)
        @add_count += 1
      end
    end
    
  end

end
