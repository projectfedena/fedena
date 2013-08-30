require 'spec_helper'

describe NewsComment do
  it { should_validate_presence_of(:author) }
  it { should_validate_presence_of(:content) }
  it { should_validate_presence_of(:news_id) }

  # it { should_belong_to(:news) }
  # it { should_belong_to(:author) }
end
