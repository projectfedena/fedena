require 'spec_helper'

describe Student do
  context 'a new student' do
    before { @student = Factory.create(:student) }

    it { should belong_to(:country) }
    it { should belong_to(:batch) }
    it { should belong_to(:student_category) }
    it { should belong_to(:nationality).class_name('Country') }
    it { should belong_to(:user) }

    it { should have_one(:student_previous_data) }

    it { should have_many(:student_previous_subject_mark) }
    it { should have_many(:guardians).dependent(:destroy) }
    it { should have_many(:finance_transactions) }
    it { should have_many(:attendances) }
    it { should have_many(:finance_fees) }
    it { should have_many(:students_subjects) }
    it { should have_many(:subjects).through(:students_subjects) }
    it { should have_many(:student_additional_details) }
    it { should have_many(:batch_students) }
    it { should have_many(:subject_leaves) }
    it { should have_many(:grouped_exam_reports) }
    it { should have_many(:cce_reports) }
    it { should have_many(:assessment_scores) }
    it { should have_many(:exam_scores) }
    it { should have_many(:previous_exam_scores) }

    #it { should validate_presence_of(:admission_no) }
    #it { should validate_presence_of(:admission_date) }
    #it { should validate_presence_of(:first_name) }
    #it { should validate_presence_of(:batch_id) }
    #it { should validate_presence_of(:date_of_birth) }
    #it { should validate_presence_of(:gender) }

    #it { should validate_uniqueness_of(:admission_no) }
    #it { should validate_format_of(:email).no_with('test@test').with_message(/invalid/) }
    #it { should validate_format_of(:admission_no).no_with('_admin+').with_message(/invalid/) }

    it 'should validate presence of admission date' do
      @student.admission_date = nil
      @student.should be_invalid
    end

    it 'should validate presence of first name' do
      @student.first_name = nil
      @student.should be_invalid
    end

    it 'should validate presence of batch' do
      @student.batch_id = nil
      @student.should be_invalid
    end

    it 'should validate presence of date of birth' do
      @student.date_of_birth = nil
      @student.should be_invalid
    end

    it 'should not have date of birth in future' do
      @student.date_of_birth = Date.today
      @student.should be_invalid
    end

    it 'should validate presence of gender attribute' do
      @student.gender = nil
      @student.should be_invalid
    end

    it 'should return correct first and last names' do
      @student.first_and_last_name.should == 'John Doe'
    end

    it 'should return correct full name' do
      @student.full_name.should == 'John K Doe'
    end

    it 'should return correct gender as text' do
      @student.gender_as_text.should == 'Male'
      @student.gender = 'f'
      @student.gender_as_text.should == 'Female'
    end

    it 'should accept m as gender attribute' do
      @student.gender = 'm'
      @student.should be_valid
      @student.gender_as_text.should == 'Male'
    end

    it 'should accept M as gender attribute' do
      @student.gender = 'M'
      @student.should be_valid
      @student.gender_as_text.should == 'Male'
    end

    it 'should accept f as gender attribute' do
      @student.gender = 'f'
      @student.should be_valid
      @student.gender_as_text.should == 'Female'
    end

    it 'should accept F as gender attribute' do
      @student.gender = 'F'
      @student.should be_valid
      @student.gender_as_text.should == 'Female'
    end

    it 'should not accept invalid gender attributes' do
      @student.gender = 'qwerty'
      @student.should be_invalid
    end

  end

end