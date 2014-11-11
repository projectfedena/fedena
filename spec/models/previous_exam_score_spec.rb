require 'spec_helper'

describe PreviousExamScore do
  it { should belong_to(:student) }
  it { should belong_to(:exam) }
  it { should belong_to(:grading_level) }
end
