require 'spec_helper'

describe News do
  it { should belong_to(:author).class_name('User') }
  it { should have_many(:comments).class_name('NewsComment') }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:content) }

  describe '#self.get_latest' do
    let(:news) { News.new }
    before { News.stub(:find).with(:all, :limit => 3).and_return([news]) }

    it 'returns latest news' do
      News.get_latest.should == [news]
    end
  end

end