class Reminder < ActiveRecord::Base
  validates_presence_of :body

  cattr_reader :per_page
  @@per_page = 12
end
