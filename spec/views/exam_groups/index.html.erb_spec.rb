require 'spec_helper'

describe "/exam_groups/index.html.erb" do

  before(:each) do
    assigns[:exam_groups] = [
      stub_model(ExamGroup),
      stub_model(ExamGroup)
    ]
  end

  it "renders a list of exam_groups" do
    render
  end
end
