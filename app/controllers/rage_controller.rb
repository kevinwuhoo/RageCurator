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
    @comics = []
    url = 'http://www.reddit.com/r/fffffffuuuuuuuuuuuu'
    doc = Nokogiri::HTML(open(url))

    doc.xpath('//a[@class="title "]').each do | method_span |  
      @comics.push [method_span.content, method_span["href"]]
    end  

    doc.xpath('//a[@class="comments"]').each_with_index do | method_span, i |  
      @comics[i].push method_span["href"]
    end  
    
  end

end
