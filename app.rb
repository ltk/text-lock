require 'sinatra'
require 'typhoeus'

post '/sms' do
  url = "https://fusion.helium.io/api/759459be-c3a4-4c41-9998-36b812a40272/lock/toggle?token=valid"
  Typhoeus.get(url)
end
