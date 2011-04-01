class RageController < ApplicationController
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

  def scrape
  end

end
