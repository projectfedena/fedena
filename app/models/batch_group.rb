class BatchGroup < ActiveRecord::Base
  belongs_to :course
  has_many :grouped_batches, :dependent=>:destroy
  has_many :batches, :through=>:grouped_batches

  validates_presence_of :name, :course_id
end
