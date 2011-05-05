# This model excepts HTML sanitization on the name
class Person < ActiveRecord::Base
  has_many :entries
  xss_terminate :except => [:name]
end
