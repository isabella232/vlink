require 'json'
require 'pry'
require 'redis'
require 'sinatra'
require 'sinatra/form_helpers'

VLINK_HASH_KEY = 'vlink'

class Link
  def initialize(link, target)
    @link = link
    @target = target
    @owners = []
  end

  def to_json(*a)
    {"#{@link}": {"target": "#{@target}", "owners": "#{@owners}"}}.to_json(*a)
  end

  def to_s
    {"#{@link}": {"target": "#{@target}", "owners": "#{@owners}"}}.to_s
  end

  def validate()
  end
end

helpers do
  def get_link(link)
    return settings.redis.hget(VLINK_HASH_KEY, link)
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
  @error = params['error'] if !params['error'].nil?
  @links = get_links()
  erb :index
end

get ('/:link') do
  link = params['link']
  site = get_link(link)
  redirect to(site) if !site.nil?
  status 404
end

get ('/error') do
  erb :error
end

# TODO(tjb): this method needs to save keys in a separate namespace per user.
# User A should be able to have a link named 'foo' that points to
# 'www.google.com', while user B should be able to have a link named 'bar'
# that also points to 'www.google.com'. Links themselves, however, must
# be unique, i.e. there can only be one http://vlink/foo
post ('/') do
  request.body.rewind
  data = request.POST['link']
  site = get_link(data['link'])
  if !site.nil?
    @error = ["#{data['link']} is already linked to #{site}"]
    redirect to ("/?error=@error")
  end
  create_link(data['link'], data['target'])
  redirect to('/') if status 201
end
