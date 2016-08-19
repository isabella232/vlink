require 'data_mapper'
require 'json'
require 'pry'
require 'sinatra'
require 'sinatra/form_helpers'
require 'sinatra/flash'
require_relative 'vlink'

enable :sessions

database_url = ENV['DATABASE_URL']
DataMapper.setup(:default, database_url)
DataMapper.finalize
Link.auto_upgrade!

configure do
  set :port, 8080
end

get ('/') do
  @links = Link.all(:order => [ :name ])
  erb :index
end

get ('/:link') do
  link = Link.first(:name => params['link'])
  return status 404 if link.nil?
  redirect to(link.target.to_s)
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
  end
  flash[:errors] = errors if !@link.saved?
  redirect to('/')
end
