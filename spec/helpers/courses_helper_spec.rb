require 'spec_helper'

describe CoursesHelper do
  describe '#setup_course' do
    let(:course) { FactoryGirl.create(:course) }
    let(:result) { helper.setup_course(course) }

    context 'when course has no batches' do
      before do
        course.batches.destroy_all
      end

      it 'build new batch' do
        result.batches.size.should == 1
        result.batches.first.should be_new_record
      end
    end

    context 'when course has batches' do
      it 'does not build new batches' do
        result.batches.should be_present
        result.batches.should == course.batches
      end
    end
  end
end
