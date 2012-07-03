class Door < ActiveRecord::Base
  has_and_belongs_to_many_with_deferred_save :rooms
end
