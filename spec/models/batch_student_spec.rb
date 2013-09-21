require 'spec_helper'

describe BatchStudent do
  it { should belong_to(:batch) }
  it { should belong_to(:student) }

  it { should validate_presence_of(:student_id) }
  it { should validate_presence_of(:batch_id) }
end