require 'spec_helper'

describe StudentAdditionalField do
  before do
    StudentAdditionalField.create(:name => 'Addition1')
  end

  it { pending"should belong_to(:student)" }
  it { pending"should belong_to(:student_additional_detail)" }
  it { should have_many(:student_additional_field_options).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_format_of(:name).not_with('A@!1').with_message('must contain only letters, numbers, and space') }
end