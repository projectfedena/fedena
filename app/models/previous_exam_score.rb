class PreviousExamScore < ActiveRecord::Base
  belongs_to :student
  belongs_to :exam
  belongs_to :grading_level
end
