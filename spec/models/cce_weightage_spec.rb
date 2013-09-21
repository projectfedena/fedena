require 'spec_helper'

describe CceWeightage do

  it { should belong_to(:cce_exam_category) }
  it { should have_and_belong_to_many(:courses) }
  it { should validate_presence_of(:weightage) }
  it { should validate_presence_of(:criteria_type) }
  it { should validate_presence_of(:cce_exam_category_id) }

end