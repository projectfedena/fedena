class BatchEvent < ActiveRecord::Base
  belongs_to :batch
  belongs_to :event
end
