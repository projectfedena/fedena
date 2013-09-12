require 'spec_helper'

describe PrivilegeTag do

  it { should have_many(:privileges) }

end