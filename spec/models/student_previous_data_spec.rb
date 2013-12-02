require 'spec_helper'

describe StudentPreviousData do

  it { should belong_to(:student) }
  it { should validate_presence_of(:institution) }

end