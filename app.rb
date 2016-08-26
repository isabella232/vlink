require 'data_mapper'
require 'json'
require 'pry'
require 'sinatra'
require 'sinatra/form_helpers'
require_relative 'vlink'

#enable :sessions
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '***REMOVED***'

database_url = ENV['DATABASE_URL'] || 'postgres://localhost/vlink'
DataMapper.setup(:default, database_url)
DataMapper.finalize
Link.auto_upgrade!

configure do
  set :server, :puma
  set :port, 8080
  set :environment, :production
  set :static_cache_control, [:public, max_age: 60 * 60 * 24 * 7]
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

get ('/') do
  @links = Link.all(:order => [ :name ])
  @error_messages = session[:error_messages]
  @link_name = session[:link_name]
  @link_target = session[:link_target]
  session[:error_messages] = session[:link_name] = session[:link_target] = nil
  erb :index
end

get ('/:link') do
  link = Link.first(:name => params['link'])
  if link.nil?
    session[:error_messages] = "/#{params['link']} does not exist. Create it?"
    session[:link_name] = "#{params['link']}"
    redirect :'/'
  end
  link.used += 1
  link.save!
  redirect to(link.target.to_s)
end

post ('/search') do
  query = params['query']
  puts "[DEBUG] Search for query: #{query}"
  @links = Link.all(:name.like => "%#{query}%")
  erb :search
end

post ('/') do
  data = {:name => request.POST['name'], :target => request.POST['target']}
  @link = Link.new(data)
  @link.save
  if !@link.saved?
    errors = ''
    @link.errors.full_messages.each do |error|
      errors << "<div>#{error}</div>\n"
    end
    session[:error_messages] = errors
    session[:link_name] = @link.name
    session[:link_target] = @link.target.to_s
  end
  redirect :'/'
end
