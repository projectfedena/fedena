require 'spec_helper'

describe BatchEvent do

  it { should belong_to(:batch) }
  it { should belong_to(:event) }

end