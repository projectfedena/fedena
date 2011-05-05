require 'spec_helper'

describe "/exam_groups/show.html.erb" do
  before(:each) do
    assigns[:exam_group] = @exam_group = stub_model(ExamGroup)
  end

  it "renders attributes in <p>" do
    render
  end
end
