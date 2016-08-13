require 'json'
require 'pry'
require 'redis'
require 'sinatra'

VLINK_HASH_KEY = 'vlink'

helpers do
  def get_link(link)
    return settings.redis.hget(link)
  end

  def get_links()
    return settings.redis.hgetall(VLINK_HASH_KEY)
  end

  def create_link(link, target)
    settings.redis.hset(VLINK_HASH_KEY, link, target)
  end
end

configure do
  set :redis, Redis.new(:url => (ENV['REDIS_PROVIDER'] || 'redis://127.0.0.1:6379/'))
end

get ('/') do
  # TODO(tjb): implement page that shows user their existing links
  # and allows them to create new links
  @links = get_links()
  erb :index
end

get ('/:link') do
  link = params['link']
  site = get_link(link)
  redirect to(site) if !site.nil?
  status 404
end

# TODO(tjb): this method needs to save keys in a separate namespace per user.
# User A should be able to have a link named 'foo' that points to
# 'www.google.com', while user B should be able to have a link named 'bar'
# that also points to 'www.google.com'. Links themselves, however, must
# be unique, i.e. there can only be one http://vlink/foo
post ('/') do
  request.body.rewind
  data = JSON.parse request.body.read
  #binding.pry
  # if link already exists, redirect to '/' with error message
  create_link(data['link'], data['target'])
  status 201
end
