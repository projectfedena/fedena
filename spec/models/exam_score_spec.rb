require 'spec_helper'

describe ExamScore do
  it { should belong_to(:student) }
  it { should belong_to(:exam) }
  it { should belong_to(:grading_level) }

  it { should validate_presence_of(:student_id) }
  it { should validate_presence_of(:exam_id).with_message("Name/Batch Name/Subject Code is invalid") }
  it { should validate_numericality_of(:marks) }

end
