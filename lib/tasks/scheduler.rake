desc "This task is called by the Heroku scheduler add-on"

task :tweet => :environment do
  require 'net/http'

  uri = URI('http://ragecurator.heroku.com/tweet')

  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth ENV['rage_curator_user'], ENV['rage_curator_pass']

  res = Net::HTTP.start(uri.hostname, uri.port) {|http|
    http.request(req)
  }
end

# task :send_reminders => :environment do
#   User.send_reminders
# end
