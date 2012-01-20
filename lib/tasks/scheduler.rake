desc "This task is called by the Heroku scheduler add-on"

task :tweet => :environment do
  # http://stackoverflow.com/questions/4581075/how-make-a-http-get-request-using-ruby-on-rails
  # http://ruby-doc.org/stdlib-1.9.3/libdoc/net/http/rdoc/Net/HTTP.html
  require 'net/http'

  # uri = URI('http://ragecurator.heroku.com/tweet')

  req = Net::HTTP::Get.new('/tweet/')
  req.basic_auth ENV['rage_curator_user'], ENV['rage_curator_pass']

  res = Net::HTTP.start('ragecurator.heroku.com', 80) {|http|
    http.request(req)
  }

  puts res.body

end

# task :send_reminders => :environment do
#   User.send_reminders
# end
