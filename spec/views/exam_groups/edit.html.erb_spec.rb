require 'spec_helper'

describe "/exam_groups/edit.html.erb" do

  before(:each) do
    assigns[:exam_groups] = @exam_group = stub_model(ExamGroup,
      :new_record? => false
    )
  end

  it "renders the edit exam_group form" do
    render

    response.should have_tag("form[action=#{exam_group_path(@exam_group)}][method=post]") do
    end
  end
end
