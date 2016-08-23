require 'data_mapper'
require 'json'
require 'pry'
require 'sinatra'
require 'sinatra/form_helpers'
require 'sinatra/flash'
require_relative 'vlink'

enable :sessions

database_url = ENV['DATABASE_URL'] || 'postgres://localhost/vlink'
DataMapper.setup(:default, database_url)
DataMapper.finalize
Link.auto_upgrade!

configure do
  set :server, :puma
  set :port, 8080
  set :environment, :production
  set :static_cache_control, [:public, max_age: 60 * 60 * 24 * 7]
end

get ('/') do
  @links = Link.all(:order => [ :name ])
  erb :index
end

get ('/:link') do
  link = Link.first(:name => params['link'])
  return status 404 if link.nil?
  link.used += 1
  link.save!
  redirect to(link.target.to_s)
end

get ('/search/:query') do
  @links = Link.all(:name.like => "%#{params['query']}%")
  erb :search
end

post ('/') do
  data = request.POST['link']
  @link = Link.new(data)
  @link.save
  if !@link.saved?
    errors = ''
    @link.errors.full_messages.each do |error|
      errors << "<div>#{error}</div>\n"
    end
    flash[:errors] = errors
    flash[:name] = @link.name
    flash[:target] = @link.target
  end
  redirect to('/')
end
