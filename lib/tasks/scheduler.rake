desc "This task is called by the Heroku scheduler add-on"

task :tweet => :environment do
  # http://stackoverflow.com/questions/4581075/how-make-a-http-get-request-using-ruby-on-rails
  # http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html
  require 'net/http'

  # uri = URI('http://ragecurator.heroku.com/tweet')

  # Original Tweet Hours, reduced now.
  # TWEET_HOURS = [16, 18, 19, 20, 21, 22, 23, 0, 1, 2, 4, 6]
  # Corresponds to PST (-8) at 8, 10, 11, 12, 13, 14, 15, 16, 18, 20, 22
  TWEET_HOURS = [18, 20, 21, 22, 23, 0, 1, 2, 4]

  # Only tweet on weekdays
  TWEET_DAYS = [1, 2, 3, 4, 5]

  # For whatever reason, console says time is in PST, but when run app is run
  # the times are in UTC
  now_hour = Time.now.gmtime.hour
  now_day = Time.now.wday
  # now_hour = Time.new.hour + 8
  # if now_hour < 0
    # now_hour += 24
  # end

  # Don't tweet if already tweeted this hour. Stops heroku's multiple
  # scheduler calling problem
  # last_comic = Comic.where(:tweet => true).order("updated_at DESC").limit(1)[0]

  # if now_hour == last_comic.updated_at.hour
    # puts "Already tweeted this hour! Currently the hour is #{now_hour}."

  # elsif TWEET_HOURS.include? now_hour
  if TWEET_HOURS.include? now_hour and TWEET_DAYS.include? now_day

    req = Net::HTTP::Get.new('/tweet/')
    req.basic_auth ENV['rage_curator_user'], ENV['rage_curator_pass']

    res = Net::HTTP.start('ragecurator.heroku.com', 80) {|http|
      http.request(req)
    }

    puts res.body

  else
    puts "Not an hour to tweet! Currently the hour is #{now_hour}."
  end

end

task :scrape => :environment do
  require 'net/http'

  req = Net::HTTP::Get.new('/scrape/')
  req.basic_auth ENV['rage_curator_user'], ENV['rage_curator_pass']

  res = Net::HTTP.start('ragecurator.heroku.com', 80) {|http|
    http.request(req)
  }

  puts res.body

end
