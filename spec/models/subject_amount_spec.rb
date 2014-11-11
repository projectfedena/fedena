require 'spec_helper'

describe SubjectAmount do
  before { @sub_amount =  SubjectAmount.create(:course => Factory.create(:course), :amount => 32, :code => 'sample_code') }

  it { should belong_to(:course) }
  it { should validate_uniqueness_of(:code).scoped_to(:course_id) }
  it { should validate_presence_of(:course_id) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:code) }
  it { should validate_numericality_of(:amount) }

end
