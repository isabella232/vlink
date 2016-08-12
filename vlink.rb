require 'json'
require 'sinatra'
require 'redis'

get ('/') do
  # TODO(tjb): implement page that shows user their existing links
  # and allows them to create new links
end

get ('/:link') do
  link = params['link']
  redis = Redis.new
  site = redis.get(link)
  redirect to(site)
end

# TODO(tjb): this method needs to save keys in a separate namespace per user.
# User A should be able to have a link named 'foo' that points to
# 'www.google.com', while user B should be able to have a link named 'bar'
# that also points to 'www.google.com'. Links themselves, however, must
# be unique, i.e. there can only be one http://vlink/foo
post ('/') do
  request.body.rewind
  data = JSON.parse request.body.read
  redis = Redis.new
  redis.set(data['key'], data['link'])
end
