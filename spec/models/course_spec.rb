require 'spec_helper'

describe Course do
  before do
    @course1 = FactoryGirl.create(:course, :is_deleted => false)
    @course2 = FactoryGirl.create(:course, :is_deleted => true)
  end

  context 'validate course' do
    it { should validate_presence_of(:course_name) }
    it { should validate_presence_of(:code) }
    it { should have_many(:batches) }
    it { should have_many(:batch_groups) }
    it { should have_many(:ranking_levels) }
    it { should have_many(:class_designations) }
    it { should have_many(:subject_amounts) }
    it { should have_and_belong_to_many(:observation_groups) }

    describe '#presence_of_initial_batch' do
      context 'no batches on create' do
        before do
          @course = FactoryGirl.build(:course)
          @course.stub_chain(:batches, :length).and_return(0)
        end

        it 'adds error to base' do
          @course.should be_invalid
          @course.errors[:base].should == 'Should have an initial batch'
        end
      end
    end
  end

  describe '#inactivate' do
    it 'sets is_deleted true' do
      @course1.inactivate
      @course1.should be_is_deleted
    end
  end

  describe '#full_name' do
    it 'returns full name of course' do
      @course = Course.new(:course_name => '1', :section_name => 'A')
      @course.full_name.should == '1 A'
    end
  end

  describe '#active_batches' do
    before do
      @course = Course.new(:course_name => '1', :section_name => 'A', :code => '1A')
      @batch1 = FactoryGirl.build(:batch, :is_active => true, :is_deleted => false)
      @batch2 = FactoryGirl.build(:batch, :is_active => true, :is_deleted => true)
      @course.batches << [@batch1, @batch2]
      @course.save
    end

    it 'returns all active batches' do
      @course.active_batches.should == [@batch1]
    end
  end

  describe '#has_batch_groups_with_active_batches' do
    context 'no active batches' do
      it 'returns false' do
        @course1.has_batch_groups_with_active_batches.should be_false
      end
    end

    context 'with active batches' do
      before do
        @batch_groups = FactoryGirl.create(:batch_group, :course => @course1)
        @batch_groups.batches = @course1.batches
      end

      it 'returns true' do
        @course1.has_batch_groups_with_active_batches.should be_true
      end
    end
  end

  describe '#cce_enabled?' do
    context 'cce is enabled in Configuration and grading type is CCE' do
      before do
        Configuration.stub(:cce_enabled?).and_return(true)
        @course1.grading_type = Course::INVERT_GRADINGTYPES['CCE']
      end

      it 'returns true' do
        @course1.should be_cce_enabled
      end
    end

    context 'cce is disabled in Configuration' do
      before do
        Configuration.stub(:cce_enabled?).and_return(false)
      end

      it 'returns false' do
        @course1.should_not be_cce_enabled
      end
    end

    context 'cce is enabled in Configuration and grading type is not CCE' do
      before do
        Configuration.stub(:cce_enabled?).and_return(true)
        @course1.grading_type = Course::INVERT_GRADINGTYPES['GPA']
      end

      it 'returns false' do
        @course1.should_not be_cce_enabled
      end
    end
  end

  describe '#gpa_enabled?' do
    context 'gpa is enabled in Configuration and grading type is GPA' do
      before do
        Configuration.stub(:has_gpa?).and_return(true)
        @course1.grading_type = Course::INVERT_GRADINGTYPES['GPA']
      end

      it 'returns true' do
        @course1.should be_gpa_enabled
      end
    end

    context 'gpa is disabled in Configuration' do
      before do
        Configuration.stub(:has_gpa?).and_return(false)
      end

      it 'returns false' do
        @course1.should_not be_gpa_enabled
      end
    end

    context 'gpa is enabled in Configuration and grading type is not GPA' do
      before do
        Configuration.stub(:has_gpa?).and_return(true)
        @course1.grading_type = Course::INVERT_GRADINGTYPES['CCE']
      end

      it 'returns false' do
        @course1.should_not be_gpa_enabled
      end
    end
  end

  describe '#normal_enabled?' do
    context 'grading type is nil' do
      before do
        @course1.grading_type = nil
      end

      it 'returns true' do
        @course1.should be_normal_enabled
      end
    end

    context 'grading type is 0' do
      before do
        @course1.grading_type = '0'
      end

      it 'returns true' do
        @course1.should be_normal_enabled
      end
    end
  end

  describe '.active' do
    it 'returns active course' do
      Course.active.should == [@course1]
    end
  end

  describe '.deleted' do
    it 'returns deleted course' do
      Course.deleted.should == [@course2]
    end
  end

  describe '.cce' do
    it 'returns CCE course' do
      @course1.grading_type = Course::INVERT_GRADINGTYPES['CCE']
      @course1.save
      Course.cce.should == [@course1]
    end
  end

end
