require 'spec_helper'

describe NewsComment do
  it { should validate_presence_of(:author) }
  it { should validate_presence_of(:content) }
  it { should validate_presence_of(:news_id) }

  it { should belong_to(:news) }
  it { should belong_to(:author).class_name("User") }
end
