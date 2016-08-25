require 'data_mapper'
require 'dm-timestamps'
require 'json'
require 'pg'

class Link
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :target, URI, :required => true, :format => :url
  property :used, Integer, :default => 0
  property :created_at, DateTime
  property :updated_at, DateTime
  property :owner, String
end
