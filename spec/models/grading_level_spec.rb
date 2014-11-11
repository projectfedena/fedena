require 'spec_helper'

describe GradingLevel do

  it { should belong_to(:batch) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:min_score) }

  describe 'validate presence of credit_points' do
    context 'batch has gpa'  do
      before { subject.stub(:batch_has_gpa?).and_return(true) }
      it { should validate_presence_of(:credit_points) }
    end

    context 'batch has no gpa'  do
      before { subject.stub(:batch_has_gpa?).and_return(false) }
      it { should_not validate_presence_of(:credit_points) }
    end
  end

  context 'a exists record' do
    let!(:grading_level) { Factory.create(:grading_level) }

    it { should validate_uniqueness_of(:name).scoped_to(:batch_id, :is_deleted) }
  end

  describe '.default' do
    let!(:grading_level1) { Factory.create(:grading_level, :batch => nil, :is_deleted => false) }
    let!(:grading_level2) { Factory.create(:grading_level, :batch => nil, :is_deleted => true) }

    it 'returns default grading level' do
      GradingLevel.default.should == [grading_level1]
    end
  end

  describe '.for_batch' do
    let!(:grading_level1) { Factory.create(:grading_level, :is_deleted => false) }
    let!(:grading_level2) { Factory.create(:grading_level, :is_deleted => false) }

    it 'return for_batch grading level' do
      GradingLevel.for_batch(grading_level2.batch_id).should == [grading_level2]
    end
  end

  describe '#inactivate' do
    let(:grading_level) { Factory.build(:grading_level, :is_deleted => false) }

    it 'does update is_deleted to true' do
      grading_level.inactivate
      grading_level.should be_is_deleted
    end
  end

  describe '#to_s' do
    let(:grading_level) { Factory.build(:grading_level, :name => 'grading level name') }

    it 'returns name of grading_level' do
      grading_level.to_s.should == 'grading level name'
    end
  end

  describe '#self.exists_for_batch?' do
    context 'batch_grades and default_grade are present' do
      before do
        grading_level = FactoryGirl.build(:grading_level)
        GradingLevel.stub(:find_all_by_batch_id).with(5, :conditions => {:is_deleted => false}).and_return([grading_level])
        GradingLevel.stub(:default).and_return([grading_level])
      end

      it 'returns true' do
        GradingLevel.exists_for_batch?(5).should be_true
      end
    end

    context 'batch_grades or default_grade is empty' do
      context 'batch_grades is empty' do
        before do
          grading_level = FactoryGirl.build(:grading_level)
          GradingLevel.stub(:find_all_by_batch_id).with(5, :conditions => {:is_deleted => false}).and_return([])
          GradingLevel.stub(:default).and_return([grading_level])
        end

        it 'returns false' do
          GradingLevel.exists_for_batch?(5).should be_false
        end
      end

      context 'default_grade is empty' do
        before do
          grading_level = FactoryGirl.build(:grading_level)
          GradingLevel.stub(:find_all_by_batch_id).with(5, :conditions => {:is_deleted => false}).and_return([grading_level])
          GradingLevel.stub(:default).and_return([])
        end

        it 'returns false' do
          GradingLevel.exists_for_batch?(5).should be_false
        end
      end
    end
  end

  describe '#self.percentage_to_grade' do
    let(:grading_level) { FactoryGirl.build(:grading_level) }

    context 'batch_grades is empty' do
      before { GradingLevel.stub(:for_batch).with(5).and_return([]) }

      context 'found GradingLevel.default with conditions' do
        before do
          GradingLevel.stub(:default).and_return([grading_level])
          GradingLevel.default.stub(:find).with(:first, :conditions => [ 'min_score <= ?', 20.round ], :order => 'min_score DESC').and_return(grading_level)
        end

        it 'returns GradingLevel.default with conditions' do
          GradingLevel.percentage_to_grade(20, 5).should == grading_level
        end
      end
    end

    context 'batch_grades is present' do
      before { GradingLevel.stub(:for_batch).with(5).and_return([grading_level]) }

      context 'found GradingLevel.for_batch(batch_id) with conditions' do
        before do
          GradingLevel.stub(:for_batch).with(5).and_return([grading_level])
          GradingLevel.for_batch(5).stub(:find).with(:first, :conditions => [ 'min_score <= ?', 20.round ], :order => 'min_score DESC').and_return(grading_level)
        end

        it 'returns GradingLevel.for_batch(batch_id) with conditions' do
          GradingLevel.percentage_to_grade(20, 5).should == grading_level
        end
      end
    end
  end

  describe '#batch_has_gpa?' do
    let(:grading_level) { Factory.build(:grading_level) }

    context 'batch_id is present, batch.gpa_enabled? is true' do
      before do
        grading_level.batch_id = 5
        grading_level.batch.stub(:gpa_enabled?).and_return(true)
      end

      it 'returns true' do
        grading_level.send(:batch_has_gpa?).should be_true
      end
    end

    context 'batch_id or batch.gpa_enabled? is false' do
      context 'batch_id is nil' do
        before do
          grading_level.batch_id = nil
          grading_level.batch.stub(:gpa_enabled?).and_return(true)
        end

        it 'returns true' do
          grading_level.send(:batch_has_gpa?).should be_false
        end
      end

      context 'batch.gpa_enabled? is false' do
        before do
          grading_level.batch.stub(:gpa_enabled?).and_return(false)
        end

        it 'returns true' do
          grading_level.send(:batch_has_gpa?).should be_false
        end
      end
    end
  end
end
