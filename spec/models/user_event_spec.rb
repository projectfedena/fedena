require 'spec_helper'

describe UserEvent do
  it { should belong_to(:user) }
  it { should belong_to(:event) }

  # it { should validate_uniqueness_of(:user_id).scoped_to(:event_id) }
end