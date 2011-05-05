require 'spec_helper'

describe "/exam_groups/new.html.erb" do
  before(:each) do
    assigns[:test_model] = stub_model(ExamGroup,
      :new_record? => true
    )
  end

  it "renders new test_model form" do
    render

    response.should have_tag("form[action=?][method=post]", exam_groups_path) do
    end
  end
end
