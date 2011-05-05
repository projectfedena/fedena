class GroupedExam < ActiveRecord::Base
  has_many :exam_groups
end
