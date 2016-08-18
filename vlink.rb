require 'data_mapper'
require 'json'
require 'pg'

class Link
  include DataMapper::Resource

  property :link, String, :key => true
  property :target, URI, :required => true
end
