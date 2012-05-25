class GroupedExamReport < ActiveRecord::Base
  belongs_to :batch
  belongs_to :student
  belongs_to :subject
end
