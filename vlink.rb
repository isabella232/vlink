require 'data_mapper'
require 'json'
require 'pg'

class Link
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :target, URI, :required => true
end
