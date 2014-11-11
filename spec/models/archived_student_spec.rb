require 'spec_helper'

describe ArchivedStudent do
  it { should belong_to(:country) }
  it { should belong_to(:batch) }
  it { should belong_to(:student_category) }
  it { should belong_to(:nationality).class_name('Country') }

  it { should have_many(:archived_guardians).dependent(:destroy) }
  it { should have_many(:students_subjects) }
  it { should have_many(:subjects) }
  it { should have_many(:cce_reports) }
  it { should have_many(:assessment_scores) }
  it { should have_many(:exam_scores) }

  describe '.before_save' do
    describe '#inactive_student' do
      let(:archived_student) { FactoryGirl.create(:archived_student, :is_active => true) }

      it 'sets student to inactive' do
        archived_student.is_active.should be_false
      end
    end
  end

  describe '#gender_as_text' do
    let(:archived_student) { FactoryGirl.create(:archived_student, :gender => gender) }

    context 'when gender is not m' do
      let(:gender) { 'f' }

      it 'returns Female' do
        archived_student.gender_as_text.should == 'Female'
      end
    end

    context 'when gender is m' do
      let(:gender) { 'm' }

      it 'returns Male' do
        archived_student.gender_as_text.should == 'Male'
      end
    end
  end

  describe '#first_and_last_name' do
    let(:archived_student) { FactoryGirl.create(:archived_student) }
    let(:result) {
      [archived_student.first_name, archived_student.last_name].join(' ')
    }

    it 'returns first and last name of student' do
      archived_student.first_and_last_name.should == result
    end
  end

  describe '#full_name' do
    let(:archived_student) { FactoryGirl.create(:archived_student) }
    let(:result) {
      [archived_student.first_name,
       archived_student.middle_name,
       archived_student.last_name].join(' ')
    }

    it 'returns first and last name of student' do
      archived_student.full_name.should == result
    end
  end

  describe '#immediate_contact' do
    let(:archived_student) { FactoryGirl.create(:archived_student, :immediate_contact_id => immediate_contact_id) }

    context 'when there is no immediate contact id' do
      let(:immediate_contact_id) { nil }

      it 'does not find the immediate contact corresponse with student' do
        archived_student.immediate_contact.should be_nil
      end
    end

    context 'when there is immediate contact id' do
      let(:immediate_contact_id) { immediate_contact.id }
      let(:immediate_contact) { FactoryGirl.create(:archived_guardian) }

      it 'finds the immediate contract corresponse with student' do
        archived_student.immediate_contact.should == immediate_contact
      end
    end
  end

  describe '#all_batches'do
    let(:archived_student) { FactoryGirl.create(:archived_student, :batch_id => batch.id) }
    let(:graduated_batches) {[batch]}
    let(:batch) { FactoryGirl.create(:batch) }

    it 'returns all batches and graduated_batches student have' do
      archived_student.should_receive(:graduated_batches).and_return(graduated_batches)
      archived_student.all_batches.should == graduated_batches + [batch]
    end
  end

  describe '#graduated_batches' do
    let(:archived_student) { FactoryGirl.create(:archived_student, :former_id => former_id) }
    let!(:batch_student) { FactoryGirl.create(:batch_student, :batch_id => batch.id,
                                                              :student_id => student_id) }
    let!(:batch) { FactoryGirl.create(:batch) }
    let(:former_id) { 1 }

    context 'when former_id is the same as student id' do
      let(:student_id) { former_id }

      it 'returns the batch' do
        archived_student.graduated_batches.should include(batch)
      end
    end

    context 'when former_id is not the same as student id' do
      let(:student_id) { former_id + 1 }

      it 'does not return the batch' do
        archived_student.graduated_batches.should_not include(batch)
      end
    end
  end

  describe '#additional_detail' do
    let(:archived_student) { FactoryGirl.create(:archived_student, :former_id => former_id) }
    let!(:additional_detail) { FactoryGirl.create(:student_additional_detail, :student_id => former_id,
                                                  :additional_field_id => additional_field.id,
                                                  :additional_info => 'Info') }
    let(:additional_field) { FactoryGirl.create(:student_additional_field) }
    let(:former_id) { 1 }

    it 'returns the student additional detail' do
      archived_student.additional_detail(additional_field.id).should == additional_detail
    end
  end

  describe '#has_retaken_exam' do
    let(:archived_student) { FactoryGirl.create(:archived_student, :former_id => former_id) }
    let(:former_id) { 1 }
    let(:subject) { FactoryGirl.create(:subject, :batch_id => batch.id) }
    let(:batch) { FactoryGirl.create(:batch, :course_id => course.id) }
    let(:course) { FactoryGirl.create(:course) }
    let(:subject_id) { subject.id }

    context 'when there are no retaken exams' do
      it 'does not retake exam' do
        archived_student.should_not have_retaken_exam(subject_id)
      end
    end

    context 'when there are retaken exam' do
      let!(:previous_exam_score) { FactoryGirl.create(:previous_exam_score, student_id: former_id,
                                                      :exam_id => exam_id) }

      context 'when student take exam of the subject' do
        let(:exam_group) { FactoryGirl.create(:exam_group) }
        let(:exam) { FactoryGirl.create(:exam, :subject_id => subject_id,
                                        :exam_group_id => exam_group.id) }
        let(:exam_id) { exam.id }

        it 'returns true' do
          archived_student.should have_retaken_exam(subject_id)
        end
      end

      context 'when student do not take exam of the subject' do
        let(:exam_id) { nil }

        it 'returns false' do
          archived_student.should_not have_retaken_exam(subject_id)
        end
      end
    end
  end
end
