# Rails HTML sanitization on some fields
class Entry < ActiveRecord::Base
  belongs_to :person
  has_many :comments
  
  xss_terminate :sanitize => [:body, :extended]
end
