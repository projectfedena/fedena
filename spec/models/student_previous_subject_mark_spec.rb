require 'spec_helper'

describe StudentPreviousSubjectMark do

  it { should belong_to(:student) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:mark) }

end