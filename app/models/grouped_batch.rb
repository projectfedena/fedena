class GroupedBatch < ActiveRecord::Base
  belongs_to :batch_group
  belongs_to :batch

  validates_presence_of :batch_group_id, :batch_id
end
