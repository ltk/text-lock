require 'sinatra'
require 'typhoeus'
require 'redis'

configure do
  uri = URI.parse(ENV["REDISCLOUD_URL"])
  $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

post '/sms' do
  lock_toggle_url = "https://fusion.helium.io/api/759459be-c3a4-4c41-9998-36b812a40272/lock/toggle?token=valid"

  puts "***** Params *****"
  puts params.inspect

  # Sample Params
  # {
  #   "ToCountry"=>"US",
  #   "ToState"=>"District Of Columbia",
  #   "SmsMessageSid"=>"SMb5740c46cc59ca79329e37a97beea74d",
  #   "NumMedia"=>"0",
  #   "ToCity"=>"",
  #   "FromZip"=>"06880",
  #   "SmsSid"=>"SMb5740c46cc59ca79329e37a97beea74d",
  #   "FromState"=>"CT",
  #   "SmsStatus"=>"received",
  #   "FromCity"=>"STAMFORD",
  #   "Body"=>"Wassup!",
  #   "FromCountry"=>"US",
  #   "To"=>"+12028001241",
  #   "ToZip"=>"",
  #   "MessageSid"=>"SMb5740c46cc59ca79329e37a97beea74d",
  #   "AccountSid"=>"AC260e990b5f7c43408e4f342a67531f01",
  #   "From"=>"+12032935763",
  #   "ApiVersion"=>"2010-04-01"
  # }

  sender = params["From"]
  lockphrase = params["Body"].chomp

  locked_by = $redis.get('locked_by')
  locked_with = $redis.get('locked_with')

  puts "Request by: #{sender}"
  puts "Request with: #{lockphrase}"

  puts "Locked by: #{locked_by}"
  puts "Locked with: #{locked_with}"

  if locked_by
    # unlock
    if (sender == locked_by) && (lockphrase == locked_with)
      puts "Unlocking..."
      Typhoeus.get(lock_toggle_url)
    end
  else
    # lock
    $redis.set('locked_by', sender)
    $redis.set('locked_with', lockphrase)
    puts "Locking..."
    Typhoeus.get(lock_toggle_url)
  end
end
