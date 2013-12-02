require 'spec_helper'

describe Privilege do

  it { should have_and_belong_to_many(:users) }
  it { should belong_to(:privilege_tag) }

end