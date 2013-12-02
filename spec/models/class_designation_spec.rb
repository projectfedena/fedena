require 'spec_helper'

describe ClassDesignation do

  it { should validate_presence_of(:name) }
  it { should belong_to(:course) }

  describe '.validate_numericality_of(cgpa)' do
    context 'has_gpa? is true' do
      before { subject.stub(:has_gpa?).and_return(true) }

      it { should validate_numericality_of(:cgpa) }
    end

    context 'has_gpa? is false' do
      before { subject.stub(:has_gpa?).and_return(false) }

      it { should_not validate_numericality_of(:cgpa) }
    end
  end

  describe '.validate_numericality_of(marks)' do
    context 'has_cwa? is true' do
      before { subject.stub(:has_cwa?).and_return(true) }

      it { should validate_numericality_of(:marks) }
    end

    context 'has_cwa? is false' do
      before { subject.stub(:has_cwa?).and_return(false) }

      it { should_not validate_numericality_of(:marks) }
    end
  end

  describe '#has_gpa?' do
    let(:class_designation) { FactoryGirl.build(:class_designation) }

    context 'course is present and course.gpa_enabled? is true' do
      let(:course) { FactoryGirl.build(:course) }
      before do
        course.stub(:gpa_enabled?).and_return(true)
        class_designation.course = course
      end

      it 'returns true' do
        class_designation.should be_has_gpa
      end
    end

    context 'course is nil or course.gpa_enabled? is false' do
      let(:course) { FactoryGirl.build(:course) }

      context 'course is nil' do
        before { class_designation.course = nil }

        it 'returns false' do
          class_designation.should_not be_has_gpa
        end
      end

      context 'course.gpa_enabled? is false' do
        before do
          class_designation.course = course
          course.stub(:gpa_enabled?).and_return(false)
        end

        it 'returns false' do
          class_designation.should_not be_has_gpa
        end
      end
    end
  end

  describe '#has_cwa?' do
    let(:class_designation) { FactoryGirl.build(:class_designation) }

    context 'course is present && (course.cwa_enabled? || course.normal_enabled?) is true' do
      let(:course) { FactoryGirl.build(:course) }
      before { class_designation.course = course }

      context 'course.cwa_enabled? is true' do
        before { course.stub(:cwa_enabled?).and_return(true) }

        it 'returns true' do
          class_designation.should be_has_cwa
        end
      end

      context 'course.normal_enabled? is true' do
        before { course.stub(:normal_enabled?).and_return(true) }

        it 'returns true' do
          class_designation.should be_has_cwa
        end
      end
    end

    context 'course is nil || (course.gpa_enabled? && course.normal_enabled?) are false' do
      let(:course) { FactoryGirl.build(:course) }

      context 'course is nil' do
        before { class_designation.course = nil }

        it 'returns false' do
          class_designation.should_not be_has_cwa
        end
      end

      context 'course.gpa_enabled? and course.normal_enabled? are false' do
        before do
          class_designation.course = course
          course.stub(:cwa_enabled?).and_return(false)
          course.stub(:normal_enabled?).and_return(false)
        end

        it 'returns false' do
          class_designation.should_not be_has_cwa
        end
      end
    end
  end

  describe '#self.human_attribute_name' do
    context 'HUMANIZED_COLUMNS include attribute symbol' do

      it 'returns value of attribute' do
        ClassDesignation.human_attribute_name('cgpa').should == 'CGPA'
      end
    end

    context 'HUMANIZED_COLUMNS not include attribute symbol' do

      it 'returns attribute' do
        ClassDesignation.human_attribute_name('Random').should == 'Random'
      end
    end
  end

end