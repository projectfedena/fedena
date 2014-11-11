require 'spec_helper'

describe CceGrade do

  it { should belong_to(:cce_grade_set) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:grade_point) }
  it { should validate_numericality_of(:grade_point) }

end