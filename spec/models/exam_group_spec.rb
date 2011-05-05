require 'spec_helper'

describe ExamGroup do
  before(:each) do
    @valid_attributes = Factory.attributes_for :exam_group
  end

  it "should create a new instance given valid attributes" do
    ExamGroup.create!(@valid_attributes)
  end
end
