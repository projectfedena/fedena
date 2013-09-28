require 'spec_helper'

describe Student do

  it { should belong_to(:country) }
  it { should belong_to(:batch) }
  it { should belong_to(:student_category) }
  it { should belong_to(:nationality).class_name('Country') }
  it { should belong_to(:user) }

  #it { should have_one(:immediate_contact) }
  it { should have_one(:student_previous_data) }

  it { should have_many(:student_previous_subject_mark) }
  it { should have_many(:guardians).dependent(:destroy) }
  it { should have_many(:finance_transactions) }
  it { should have_many(:attendances) }
  it { should have_many(:finance_fees) }
  #it { should have_many(:fee_category).class_name('FinanceFeeCategory') }
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

  context 'a exists record' do
    subject { FactoryGirl.create(:student) }
    #it { should validate_uniqueness_of(:admission_no) }
    #it { should validate_presence_of(:admission_no) }
    it { should validate_presence_of(:admission_date) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:batch_id) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:gender) }
    it { should allow_value('m').for(:gender) }
    it { should allow_value('f').for(:gender) }
    it { should allow_value('M').for(:gender) }
    it { should allow_value('F').for(:gender) }

    it { should validate_format_of(:email).not_with('test@test').with_message(I18n.t('must_be_a_valid_email_address')) }
    #it { should validate_format_of(:admission_no).not_with('_admin+').with_message(I18n.t('must_contain_only_letters')) }
  end

  describe '#date_of_birth_must_not_be_future' do
    let!(:student) { FactoryGirl.create(:student) }

    context 'date_of_birth >= Date.current' do
      before { student.date_of_birth = Date.current + 3.days }

      it 'returns invalid' do
        student.should be_invalid
      end
    end
  end

  describe '#check_admission_no' do
    let!(:student) { FactoryGirl.create(:student) }

    context 'admission_no = 0' do
      before { student.admission_no = '0' }

      it 'returns invalid' do
        student.should be_invalid
      end
    end

    context 'downcase admission_no = admin' do
      before { student.admission_no = 'Admin' }

      it 'returns invalid' do
        student.should be_invalid
      end
    end
  end

  describe '#create_user_and_validate' do
    context 'student is new record' do
      let(:student) { FactoryGirl.build(:student, :first_name => 'FN', :last_name => 'LN', :admission_no => '111') }

      context 'student.email is blank' do
        before do
          student.email = ''
          student.save
        end

        it 'does set user.first_name = student.first_name' do
          student.user.first_name.should == 'FN'
        end

        it 'does set user.last_name = student.last_name' do
          student.user.last_name.should == 'LN'
        end

        it 'does set user.username = student.username' do
          student.user.username.should == '111'
        end

        it 'does set user.password = student.password' do
          student.user.password.should == '111123'
        end

        it 'does set user.role = Student' do
          student.user.role.should == 'Student'
        end

        it 'does set user.email blank' do
          student.user.email.should == ''
        end

        it 'does set user.email blank' do
          student.email.should == ''
        end
      end

      context 'student.email is present' do
        before { student.email = 'admin@fedena.com' }

        it 'does set user.email = student.email' do
          student.save
          student.user.email.should == 'admin@fedena.com'
        end
      end

      it 'call check_user_errors' do
        student.should_receive(:check_user_errors)
        student.save
      end

      context 'student has any errors' do
        before { student.stub(:errors).and_return(['errors'])}

        it 'returns false' do
          student.save.should be_false
        end
      end
    end

    context 'student is not new record' do
      let(:student) { FactoryGirl.create(:student, :first_name => 'FN', :last_name => 'LN', :admission_no => '111') }

        context 'new info student' do
          before do
            student.admission_no = '222'
            student.first_name = 'FN_NEW'
            student.last_name = 'LN_NEW'
            student.email = 'admin_new@fedena.com'
          end

          it 'does set user.role = Student' do
            student.user.role.should == 'Student'
          end

          context 'check_changes includes admission_no, first_name, last_name, email, immediate_contact_id' do
            before { student.stub(:changed).and_return(['admission_no','first_name','last_name','email','immediate_contact_id']) }

            context 'update student info' do
              before { student.save }
              it 'does set user.first_name = student.first_name' do
                student.user.first_name.should == 'FN_NEW'
              end

              it 'does set user.last_name = student.last_name' do
                student.user.last_name.should == 'LN_NEW'
              end

              it 'does set user.username = student.username' do
                student.user.username.should == '222'
              end

              it 'does set user.email blank' do
                student.user.email.should == 'admin_new@fedena.com'
              end
            end

            it 'call check_user_errors' do
              student.should_receive(:check_user_errors)
              student.save
            end

            it 'call Guardian shift_user' do
              Guardian.should_receive(:shift_user)
              student.save
            end
          end
        end
    end
  end

  describe '#is_active_true' do
    let(:student) { FactoryGirl.build(:student, :is_active => false) }

    it 'does update is_active to true' do
      student.save
      student.should be_is_active
    end
  end

  describe '#check_user_errors' do
    let(:admin_user) { FactoryGirl.build(:admin_user) }
    let(:student) { FactoryGirl.build(:student) }

    context 'user valid fail' do
      before do
        admin_user.stub(:valid?).and_return(false)
        admin_user.stub(:errors).and_return(['base'])
      end

      it 'returns false' do
        student.check_user_errors(admin_user).should be_false
      end
    end
  end

  describe '#first_and_last_name' do
    let(:student) { FactoryGirl.build(:student, :first_name => 'FN', :last_name => 'LN') }

    it 'returns full name' do
      student.first_and_last_name.should == 'FN LN'
    end
  end

  describe '#first_and_last_name' do
    let(:student) { FactoryGirl.build(:student, :first_name => 'FN', :last_name => 'LN') }

    it 'returns first and last name' do
      student.first_and_last_name.should == 'FN LN'
    end
  end

  describe '#full_name' do
    let(:student) { FactoryGirl.build(:student, :first_name => 'FN', :middle_name => 'MN', :last_name => 'LN') }

    it 'returns full name' do
      student.full_name.should == 'FN MN LN'
    end
  end

  describe '#gender_as_text' do
    let(:student) { FactoryGirl.build(:student) }

    context 'downcase gender = m' do
      before { student.gender = 'M' }

      it 'returns Male' do
        student.gender_as_text.should == 'Male'
      end
    end

    context 'downcase gender = f' do
      before { student.gender = 'F' }

      it 'returns Female' do
        student.gender_as_text.should == 'Female'
      end
    end

    context 'not found gender' do
      before { student.gender = 'a' }

      it 'returns nil' do
        student.gender_as_text.should == nil
      end
    end
  end

  describe '#graduated_batches' do
    let(:batch_student) { FactoryGirl.build(:batch_student) }
    let(:student) { FactoryGirl.build(:student, :batch_students => [batch_student]) }

    it 'returns all batch of batch_students' do
      student.graduated_batches.should == [batch_student.batch]
    end
  end

  describe '#all_batches' do
    let(:batch) { FactoryGirl.build(:batch) }
    let(:student) { FactoryGirl.build(:student) }
    before { student.stub(:graduated_batches).and_return([batch]) }

    it 'returns all batch' do
      student.all_batches.should == [batch, student.batch]
    end
  end

  describe '#immediate_contact' do
    let(:student) { FactoryGirl.build(:student) }

    context 'immediate_contact_id is present' do
      let(:guardian) { FactoryGirl.build(:guardian) }
      before do
        student.immediate_contact_id = 5
        Guardian.stub(:find).with(5).and_return(guardian)
      end

      it 'returns Guardian with immediate_contact_id' do
        student.immediate_contact.should == guardian
      end
    end
  end

  describe '#next_student' do
    let(:student1) { FactoryGirl.build(:student) }
    let(:student2) { FactoryGirl.build(:student) }

    context 'found Student with conditions' do
      before do
        student.batch.stub(:students).and_return([student1, student2])
        student.batch.students.stub(:first).with(:conditions => ["id > ?", student.id], :order => "id ASC").and_return(student2)

        it 'returns next_student' do
          student.next_student.should == student2
        end
      end
    end

    context 'not found Student with conditions' do
      before do
        student.batch.stub(:students).and_return([student1, student2])
        student.batch.students.stub(:first).with(:conditions => ["id > ?", student.id], :order => "id ASC").and_return(nil)

        context 'found Student with order id ASC' do
          before { student.batch.students.stub(:first).with(:order => "id DESC").and_return(student2) }
          it 'returns next_student' do
            student.next_student.should == student2
          end
        end
      end
    end
  end

  describe '#previous_student' do
    let(:student1) { FactoryGirl.build(:student) }
    let(:student2) { FactoryGirl.build(:student) }

    context 'found Student with conditions' do
      before do
        student.batch.stub(:students).and_return([student1, student2])
        student.batch.students.stub(:first).with(:conditions => ["id < ?", student.id], :order => "admission_no DESC").and_return(student2)

        it 'returns previous_student' do
          student.previous_student.should == student2
        end
      end
    end

    context 'not found Student with conditions' do
      before do
        student.batch.stub(:students).and_return([student1, student2])
        student.batch.students.stub(:first).with(:conditions => ["id < ?", student.id], :order => "admission_no DESC").and_return(nil)

        context 'found Student with order id DESC' do
          before { student.batch.students.stub(:first).with(:order => "id DESC").and_return(student2) }
          it 'returns previous_student' do
            student.previous_student.should == student2
          end
        end
      end
    end
  end

  describe '#previous_fee_student' do
    let(:date) { 5 }
    let(:student) { FactoryGirl.build(:student) }

    context 'found FinanceFee with conditions' do
      let(:finance_fee) { FactoryGirl.build(:finance_fee) }
      before { FinanceFee.stub(:first).with(:conditions => ["student_id < ? AND fee_collection_id = ?", student.id, date], :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id DESC").and_return(finance_fee) }

      it 'returns previous fee student' do
        student.previous_fee_student(date).should == finance_fee.student
      end
    end

    context 'not found FinanceFee with conditions' do

      before { FinanceFee.stub(:first).with(:conditions => ["student_id < ? AND fee_collection_id = ?", student.id, date], :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id DESC").and_return(nil) }

      context 'found FinanceFee with another conditions' do
        let(:finance_fee) { FactoryGirl.build(:finance_fee) }
        before { FinanceFee.stub(:find_by_fee_collection_id).with(date, :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id DESC").and_return(finance_fee) }

        it 'returns previous fee student' do
          student.previous_fee_student(date).should == finance_fee.student
        end
      end
    end
  end

  describe '#next_fee_student' do
    let(:date) { 5 }
    let(:student) { FactoryGirl.build(:student) }

    context 'found FinanceFee with conditions' do
      let(:finance_fee) { FactoryGirl.build(:finance_fee) }
      before { FinanceFee.stub(:first).with(:conditions => ["student_id > ? AND fee_collection_id = ?", student.id, date], :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id ASC").and_return(finance_fee) }

      it 'returns next fee student' do
        student.next_fee_student(date).should == finance_fee.student
      end
    end

    context 'not found FinanceFee with conditions' do

      before { FinanceFee.stub(:first).with(:conditions => ["student_id > ? AND fee_collection_id = ?", student.id, date], :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id ASC").and_return(nil) }

      context 'found FinanceFee with another conditions' do
        let(:finance_fee) { FactoryGirl.build(:finance_fee) }
        before { FinanceFee.stub(:find_by_fee_collection_id).with(date, :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id ASC").and_return(finance_fee) }

        it 'returns next fee student' do
          student.next_fee_student(date).should == finance_fee.student
        end
      end
    end
  end

  describe '#finance_fee_by_date' do
    let(:date) { FactoryGirl.build(:finance_fee_collection) }
    let(:finance_fee) { FactoryGirl.build(:finance_fee) }
    let(:student) { FactoryGirl.build(:student) }
    before { FinanceFee.stub(:find_by_fee_collection_id_and_student_id).with(date.id, student.id).and_return(finance_fee) }

    it 'returns FinanceFee with fee_collection_id and student_id' do
      student.finance_fee_by_date(date).should == finance_fee
    end
  end

  describe '#check_fees_paid' do
    let(:date) { FactoryGirl.build(:finance_fee_collection) }
    let(:finance_fee) { FactoryGirl.build(:finance_fee) }
    let(:student) { FactoryGirl.build(:student) }

    context 'found all fees_particulars of student' do
      let(:fee_collection_particular) { FactoryGirl.build(:fee_collection_particular, :amount => 40) }
      before { date.stub(:fees_particulars).and_return([fee_collection_particular]) }

      context 'found FinanceFee with student.id' do
        let(:finance_fee) { FactoryGirl.build(:finance_fee) }
        before { date.stub(:fee_transactions).and_return(finance_fee) }

        context 'batch_discounts is present' do
          let(:batch_fee_collection_discount) { FactoryGirl.build(:batch_fee_collection_discount, :discount => 15) }
          before { BatchFeeCollectionDiscount.stub(:find_all_by_finance_fee_collection_id).and_return([batch_fee_collection_discount]) }

          context 'student_discounts is present' do
            let(:student_fee_collection_discount) { FactoryGirl.build(:student_fee_collection_discount, :discount => 25) }
            before { StudentFeeCollectionDiscount.stub(:find_all_by_finance_fee_collection_id_and_receiver_id).and_return([student_fee_collection_discount]) }

            context 'category_discounts is present' do
              let(:student_category_fee_collection_discount) { FactoryGirl.build(:student_category_fee_collection_discount, :discount => 10) }
              before { StudentCategoryFeeCollectionDiscount.stub(:find_all_by_finance_fee_collection_id_and_receiver_id).and_return([student_category_fee_collection_discount]) }

              context 'found FinanceTransaction with conditions' do
                let(:finance_transaction) { FactoryGirl.build(:finance_transaction, :amount => 20, :fine_amount => 15) }
                before { FinanceTransaction.stub(:find).with(:all,:select=>'amount, fine_amount', :conditions => ["FIND_IN_SET(id, ?)", finance_fee.transaction_id]).and_return([finance_transaction]) }

                context 'when amount pendding != 0' do
                  it 'returns false' do
                    student.check_fees_paid(date).should be_false
                  end
                end

                context 'when amount pendding = 0' do
                  before do
                    finance_transaction.amount = 25
                    finance_transaction.fine_amount = 5
                  end

                  it 'returns true' do
                    student.check_fees_paid(date).should be_true
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  describe '#has_retaken_exam?' do
    let(:subject_id) { 10 }
    let(:student) { FactoryGirl.build(:student) }

    context 'retaken_exams has any' do
      let(:previous_exam_score) { FactoryGirl.build(:previous_exam_score) }
      before { PreviousExamScore.stub(:find_all_by_student_id).and_return([previous_exam_score]) }

      context 'Exam includes subject_id' do
        let(:exam) { FactoryGirl.build(:exam, :subject_id => subject_id) }
        before { Exam.stub(:find_all_by_id).and_return([exam]) }

        it 'returns true' do
          student.has_retaken_exam?(subject_id).should be_true
        end
      end

      context 'Exam not includes subject_id' do
        before { Exam.stub(:find_all_by_id).and_return([]) }

        it 'returns false' do
          student.has_retaken_exam?(subject_id).should be_false
        end
      end
    end

    context 'retaken_exams is empty' do
      before { PreviousExamScore.stub(:find_all_by_student_id).and_return([]) }

      it 'returns false' do
        student.has_retaken_exam?(subject_id).should be_false
      end
    end
  end

  describe '#check_fee_pay' do
    let(:finance_fee) { FactoryGirl.build(:finance_fee) }
    let(:date) { FactoryGirl.build(:finance_fee_collection, :finance_fees => [finance_fee]) }
    let(:student) { FactoryGirl.build(:student) }

    context 'finance_fee.is_paid is true' do
      before do
        finance_fee.is_paid = true
        date.finance_fees.stub(:first).with(:conditions => ["student_id = ?", student.id]).and_return(finance_fee)
      end

      it 'returns true' do
        student.check_fee_pay(date).should be_true
      end
    end

    context 'finance_fee.is_paid is false' do
      before do
        finance_fee.is_paid = false
        date.finance_fees.stub(:first).with(:conditions => ["student_id = ?", student.id]).and_return(finance_fee)
      end

      it 'returns false' do
        student.check_fee_pay(date).should be_false
      end
    end
  end

  describe '#get_fee_strucure_elements' do
    let(:date) { FactoryGirl.build(:finance_fee_collection) }
    let(:student) { FactoryGirl.build(:student) }

    context 'has elements' do
      before do
        elements = {}
        elements[:all] = [1]
        elements[:by_batch] = [2]
        elements[:by_category] = [3]
        elements[:by_batch_and_category] = [4]
        FinanceFeeStructureElement.stub(:get_student_fee_components).and_return(elements)
      end

      it 'returns fee_strucure_elements' do
        student.get_fee_strucure_elements(date).should == [1, 2, 3, 4]
      end
    end
  end

  describe '#total_fees' do
    let(:student) { FactoryGirl.build(:student) }
    let(:particular1) { FactoryGirl.build(:finance_fee_particular, :amount => 15) }
    let(:particular2) { FactoryGirl.build(:finance_fee_particular, :amount => 25) }

    it 'returns total amount' do
      student.total_fees([particular1, particular2]).should == 40
    end
  end

  describe '#has_associated_fee_particular?' do
    let(:fee_particular) { FactoryGirl.build(:finance_fee_particular) }
    let(:fee_category) { FactoryGirl.build(:finance_fee_category, :fee_particulars => [fee_particular]) }
    let(:student) { FactoryGirl.build(:student) }

    context 'not found fee_particulars wiht by_admission_no' do
      before { fee_category.fee_particulars.stub(:find_all_by_admission_no).and_return([]) }

      context 'student_category_id is present' do
        before { student.student_category_id = 5 }

        context 'not found fee_particulars with student_category_id' do
          before { fee_category.fee_particulars.stub(:find_all_by_student_category_id).and_return([]) }

          it 'returns false' do
            student.has_associated_fee_particular?(fee_category).should be_false
          end
        end

        context 'found fee_particulars with student_category_id' do
          before { fee_category.fee_particulars.stub(:find_all_by_student_category_id).and_return([1,2]) }

          it 'returns true' do
            student.has_associated_fee_particular?(fee_category).should be_true
          end
        end
      end
    end

    context 'found fee_particulars wiht by_admission_no' do
      before { fee_category.fee_particulars.stub(:find_all_by_admission_no).and_return([1,2]) }

      it 'returns true' do
        student.has_associated_fee_particular?(fee_category).should be_true
      end
    end
  end

  describe '#archive_student' do
    let(:user) { FactoryGirl.build(:admin_user, :is_deleted => false) }
    let(:guardian) { FactoryGirl.build(:guardian) }
    let(:student) { FactoryGirl.build(:student, :id => 10, :user => user, :guardians => [guardian]) }

    context 'archived student is vaild' do
      before { ArchivedStudent.any_instance.expects(:valid?).returns(true) }

      context 'save info archived_student' do
        before { student.archive_student('status') }
        let(:archived_student) { ArchivedStudent.first }

        it 'does update former_id = student.id' do
          archived_student.former_id.should == '10'
        end

        it 'does update status_description = status' do
          archived_student.status_description.should == 'status'
        end

        it 'does update student.user.is_deleted to true' do
          student.user.should be_is_deleted
        end

        it 'destroy student' do
          student.should be_destroyed
        end
      end

      context 'archived guardian' do
        it 'call archive_guardian' do
          guardian.should_receive(:archive_guardian)
          student.archive_student('status')
        end
      end
    end
  end

  describe '#check_dependency' do
    let(:student) { FactoryGirl.build(:student) }

    context 'all conditions are nil' do
      before do
        student.stub(:finance_transactions).and_return(nil)
        student.stub(:graduated_batches).and_return(nil)
        student.stub(:attendances).and_return(nil)
        student.stub(:finance_fees).and_return(nil)
        FedenaPlugin.stub(:check_dependency).and_return(nil)
      end

      it 'returns false' do
        student.check_dependency.should be_false
      end

      context 'one of which is true' do
        context 'finance_transactions is true' do
          before { student.stub(:finance_transactions).and_return(true) }

          it 'returns true' do
            student.check_dependency.should be_true
          end
        end

        context 'graduated_batches is true' do
          before { student.stub(:graduated_batches).and_return(true) }

          it 'returns true' do
            student.check_dependency.should be_true
          end
        end

        context 'attendances is true' do
          before { student.stub(:attendances).and_return(true) }

          it 'returns true' do
            student.check_dependency.should be_true
          end
        end

        context 'finance_fees is true' do
          before { student.stub(:finance_fees).and_return(true) }

          it 'returns true' do
            student.check_dependency.should be_true
          end
        end

        context 'FedenaPlugin check_dependency is true' do
          before { FedenaPlugin.stub(:check_dependency).and_return(true) }

          it 'returns true' do
            student.check_dependency.should be_true
          end
        end
      end
    end
  end

  describe '#former_dependency' do
    let(:student) { FactoryGirl.build(:student) }
    before { FedenaPlugin.stub(:check_dependency).and_return([1, 2]) }

    it 'returns FedenaPlugin check_dependency' do
      student.former_dependency.should == [1, 2]
    end
  end

  describe '#assessment_score_for' do
    let(:assessment_score) { FactoryGirl.build(:assessment_score) }
    let(:student) { FactoryGirl.build(:student, :assessment_scores => [assessment_score]) }

    context 'found assessment_score with student_id, descriptive_indicator_id, exam_id, batch_id' do
      before { student.assessment_scores.stub(:find_by_student_id_and_descriptive_indicator_id_and_exam_id_and_batch_id).and_return(assessment_score) }

      it 'returns assessment_score' do
        student.assessment_score_for(5 ,6 ,7).should == assessment_score
      end
    end

    context 'not found assessment_score with student_id, descriptive_indicator_id, exam_id, batch_id' do
      before { student.assessment_scores.stub(:find_by_student_id_and_descriptive_indicator_id_and_exam_id_and_batch_id).and_return(nil) }

      context 'build assessment_score new record' do
        let(:new_assessment_score) { FactoryGirl.build(:assessment_score, :descriptive_indicator_id => 5, :exam_id => 6, :batch_id => 7) }

        it 'returns new_assessment_score' do
          #student.assessment_score_for(5 ,6 ,7).should == new_assessment_score
        end
      end
    end
  end

  describe '#observation_score_for' do
    let(:assessment_score) { FactoryGirl.build(:assessment_score) }
    let(:student) { FactoryGirl.build(:student, :assessment_scores => [assessment_score]) }

    context 'found assessment_score with student_id, descriptive_indicator_id, batch_id' do
      before { student.assessment_scores.stub(:find_by_student_id_and_descriptive_indicator_id_and_batch_id).and_return(assessment_score) }

      it 'returns assessment_score' do
        student.observation_score_for(5 ,6).should == assessment_score
      end
    end

    context 'not found assessment_score with student_id, descriptive_indicator_id, batch_id' do
      before { student.assessment_scores.stub(:find_by_student_id_and_descriptive_indicator_id_and_batch_id).and_return(nil) }

      context 'build assessment_score new record' do
        let(:new_assessment_score) { FactoryGirl.build(:assessment_score, :descriptive_indicator_id => 5, :batch_id => 7) }

        it 'returns new_assessment_score' do
          #student.observation_score_for(5 ,6).should == new_assessment_score
        end
      end
    end
  end

  describe '#has_higher_priority_ranking_level' do
    let(:ranking_level_id) { 5 }
    let(:subject_id) { 7 }
    let(:student) { FactoryGirl.build(:student) }

    context 'found RankingLevel with ranking_level_id' do
      let(:ranking_level) { FactoryGirl.build(:ranking_level) }
      before { RankingLevel.stub(:find).with(ranking_level_id).and_return(ranking_level) }

      context 'higher_levels is empty' do
        before { RankingLevel.stub(:find).with(:all,:conditions=>["course_id = ? AND priority < ?", ranking_level.course_id,ranking_level.priority]).and_return([]) }

        it 'returns false' do
          student.has_higher_priority_ranking_level(ranking_level_id, 'type', subject_id).should be_false
        end
      end

      context 'higher_levels is any' do
        before { RankingLevel.stub(:find).with(:all,:conditions=>["course_id = ? AND priority < ?", ranking_level.course_id,ranking_level.priority]).and_return([ranking_level]) }

        context 'type = subject' do
          let(:type) { 'subject' }

          context 'found GroupedExamReport with conditions' do
            let(:score) { FactoryGirl.build(:grouped_exam_report) }
            before { GroupedExamReport.stub(:find_by_student_id_and_subject_id_and_batch_id_and_score_type).and_return(score) }

            context 'check_score_marks is true' do
              before { student.stub(:check_score_marks).and_return(true) }

              it 'returns true' do
                student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
              end
            end

            context 'check_score_marks is false' do
              before { student.stub(:check_score_marks).and_return(false) }

              it 'returns false' do
                student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
              end
            end
          end
        end

        context 'type = overall' do
          let(:type) { 'overall' }
          context 'level.subject_count is present' do
            before { ranking_level.subject_count = 5 }

            context 'level.full_course is false' do
              before { ranking_level.full_course = false }

              context 'with batch subjects' do
                let(:subject) { FactoryGirl.build(:general_subject) }
                before { student.batch.stub(:subjects).and_return([subject]) }

                context 'found GroupedExamReport with student_id, batch_id, subject_id, score_type' do
                  let(:score) { FactoryGirl.build(:grouped_exam_report) }
                  before { GroupedExamReport.stub(:find_all_by_student_id_and_batch_id_and_subject_id_and_score_type).and_return([score]) }

                  context 'not reject score with false conditions' do
                    before { student.stub(:reject_scores).and_return([score]) }

                    context 'check_scores_count_and_subject_count is true' do
                      before { student.stub(:check_scores_count_and_subject_count).and_return(true) }

                      it 'returns true' do
                        student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                      end
                    end

                    context 'check_scores_count_and_subject_count is fasle' do
                      before { student.stub(:check_scores_count_and_subject_count).and_return(false) }

                      it 'returns false' do
                        student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                      end
                    end
                  end
                end
              end
            end

            context 'level.full_course is true' do
              before { ranking_level.full_course = true }

              context 'scores is any' do
                context 'found GroupedExamReport with conditions' do
                  let(:score) { FactoryGirl.build(:grouped_exam_report) }
                  before { GroupedExamReport.stub(:find_all_by_student_id_and_score_type).with(student.id, 's').and_return([score]) }

                  context 'not reject score with false conditions' do
                    before { student.stub(:reject_scores).and_return([score]) }

                    context 'check_scores_count_and_subject_count is true' do
                      before { student.stub(:check_scores_count_and_subject_count).and_return(true) }

                      it 'returns true' do
                        student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                      end
                    end

                    context 'check_scores_count_and_subject_count is fasle' do
                      before { student.stub(:check_scores_count_and_subject_count).and_return(false) }

                      it 'returns false' do
                        student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                      end
                    end
                  end
                end
              end
            end
          end

          context 'level.subject_count is nil' do
            before { ranking_level.subject_count = nil }

            context 'ranking_level.full_course is false' do
              before { ranking_level.full_course = false }

              context 'found GroupedExamReport with student_id' do
                let(:score) { FactoryGirl.build(:grouped_exam_report) }
                before { GroupedExamReport.stub(:find_by_student_id_and_batch_id_and_score_type).and_return(score) }

                context 'check_score_marks is true' do
                  before { student.stub(:check_score_marks).and_return(true) }

                  it 'returns true' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                  end
                end

                context 'check_score_marks is false' do
                  before { student.stub(:check_score_marks).and_return(false) }

                  it 'returns false' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                  end
                end
              end
            end

            context 'ranking_level.full_course is true' do
              before { ranking_level.full_course = true }

              context 'found GroupedExamReport with student_id, score_type' do
                let(:score) { FactoryGirl.build(:grouped_exam_report, :marks => 20) }
                before { GroupedExamReport.stub(:find_all_by_student_id_and_score_type).and_return([score]) }

                context 'check_score_marks is true' do
                  before { student.stub(:check_score_marks).and_return(true) }

                  it 'returns true' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                  end
                end

                context 'check_score_marks is false' do
                  before { student.stub(:check_score_marks).and_return(false) }

                  it 'returns false' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                  end
                end
              end
            end
          end
        end

        context 'type == course' do
          let(:type) { 'course' }

          context 'level.subject_count is present' do
            before { ranking_level.subject_count = 5 }

            context 'found GroupedExamReport with conditions' do
              let(:score) { FactoryGirl.build(:grouped_exam_report, :student => student) }
              before { GroupedExamReport.stub(:find_all_by_student_id_and_score_type).with(student.id, 's').and_return([score]) }

              context 'score is any' do
                context 'not reject score with false conditions' do
                  before { student.stub(:reject_scores).and_return([score]) }

                  context 'level.full_course = false' do
                    before { ranking_level.full_course = false }

                    context 'batch_ids is any' do
                      before { score.batch_id = 11 }

                      context 'check_scores_count_and_subject_count is true' do
                        before { student.stub(:check_scores_count_and_subject_count).and_return(true) }

                        it 'returns true' do
                          student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                        end
                      end

                      context 'check_scores_count_and_subject_count is false' do
                        before { student.stub(:check_scores_count_and_subject_count).and_return(false) }

                        it 'returns false' do
                          student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                        end
                      end
                    end
                  end

                  context 'level.full_course = true' do
                    before { ranking_level.full_course = true }

                    context 'check_scores_count_and_subject_count is true' do
                      before { student.stub(:check_scores_count_and_subject_count).and_return(true) }

                      it 'returns true' do
                        student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                      end
                    end

                    context 'check_scores_count_and_subject_count is false' do
                      before { student.stub(:check_scores_count_and_subject_count).and_return(false) }

                      it 'returns false' do
                        student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                      end
                    end
                  end
                end
              end
            end
          end

          context 'level.subject_count is nil' do
            before { ranking_level.subject_count = nil }

            context 'level.full_course = false' do
              before { ranking_level.full_course = false }

              context 'found GroupedExamReport with student_id, score_type' do
                let(:score) { FactoryGirl.build(:grouped_exam_report) }
                before { GroupedExamReport.stub(:find_all_by_student_id_and_score_type).and_return([score]) }

                context 'not reject score with false conditions' do
                  before { student.stub(:reject_scores).and_return([score]) }

                  it 'returns true' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                  end
                end

                context 'reject score with true conditions' do
                  before { student.stub(:reject_scores).and_return([]) }

                  it 'returns false' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                  end
                end
              end
            end

            context 'level.full_course = true' do
              before { ranking_level.full_course = true }

              context 'found GroupedExamReport with student_id, score_type' do
                let(:score) { FactoryGirl.build(:grouped_exam_report, :marks => 20) }
                before { GroupedExamReport.stub(:find_all_by_student_id_and_score_type).and_return([score]) }

                context 'check_score_marks is true' do
                  before { student.stub(:check_score_marks).and_return(true) }

                  it 'returns true' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_true
                  end
                end

                context 'check_score_marks is false' do
                  before { student.stub(:check_score_marks).and_return(false) }

                  it 'returns false' do
                    student.has_higher_priority_ranking_level(ranking_level_id, type, subject_id).should be_false
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  describe '#check_score_marks' do
    let(:score_marks) { 20 }
    let(:level) { FactoryGirl.build(:ranking_level) }
    let(:student) { FactoryGirl.build(:student) }

    context 'student.batch.gpa_enabled? is true' do
      before { student.batch.stub(:gpa_enabled?).and_return(true) }

      context 'level.marks_limit_type == upper' do
        before { level.marks_limit_type = 'upper' }

        context 'score_marks < level.gpa' do
          let(:score_marks) { 10 }
          before { level.gpa = 20 }

          it 'returns true' do
            student.send(:check_score_marks, score_marks, level).should be_true
          end
        end
      end

      context 'level.marks_limit_type == exact' do
        before { level.marks_limit_type = 'exact' }

        context 'score_marks = level.gpa' do
          let(:score_marks) { 20 }
          before { level.gpa = 20 }

          it 'returns true' do
            student.send(:check_score_marks, score_marks, level).should be_true
          end
        end
      end

      context 'level.marks_limit_type == lower' do
        before { level.marks_limit_type = 'lower' }

        context 'score_marks >= level.gpa' do
          let(:score_marks) { 21 }
          before { level.gpa = 20 }

          it 'returns true' do
            student.send(:check_score_marks, score_marks, level).should be_true
          end
        end
      end
    end

    context 'student.batch.gpa_enabled? is false' do
      before { student.batch.stub(:gpa_enabled?).and_return(false) }

      context 'level.marks_limit_type == upper' do
        before { level.marks_limit_type = 'upper' }

        context 'score_marks < level.marks' do
          let(:score_marks) { 10 }
          before { level.marks = 20 }

          it 'returns true' do
            student.send(:check_score_marks, score_marks, level).should be_true
          end
        end
      end

      context 'level.marks_limit_type == exact' do
        before { level.marks_limit_type = 'exact' }

        context 'score_marks = level.marks' do
          let(:score_marks) { 20 }
          before { level.marks = 20 }

          it 'returns true' do
            student.send(:check_score_marks, score_marks, level).should be_true
          end
        end
      end

      context 'level.marks_limit_type == lower' do
        before { level.marks_limit_type = 'lower' }

        context 'score_marks >= level.marks' do
          let(:score_marks) { 21 }
          before { level.marks = 20 }

          it 'returns true' do
            student.send(:check_score_marks, score_marks, level).should be_true
          end
        end
      end
    end
  end

  describe '#reject_scores' do
    let(:score) { FactoryGirl.build(:grouped_exam_report) }
    let(:level) { FactoryGirl.build(:ranking_level) }
    let(:student) { FactoryGirl.build(:student) }

    context 'student.batch.gpa_enabled? is true' do
      before { student.batch.stub(:gpa_enabled?).and_return(true) }

      context 'level.marks_limit_type = upper' do
        before { level.marks_limit_type = 'upper' }

        context 'not reject with score.marks < level.gpa' do
          before do
            score.marks = 10
            level.gpa = 20
          end

          it 'returns scores' do
            student.send(:reject_scores, [score], level).should == [score]
          end
        end

        context 'reject with score.marks >= level.gpa' do
          before do
            score.marks = 21
            level.gpa = 20
          end

          it 'returns empty' do
            student.send(:reject_scores, [score], level).should == []
          end
        end
      end

      context 'level.marks_limit_type = lower' do
        before { level.marks_limit_type = 'lower' }

        context 'not reject with score.marks >= level.gpa' do
          before do
            score.marks = 21
            level.gpa = 20
          end

          it 'returns scores' do
            student.send(:reject_scores, [score], level).should == [score]
          end
        end

        context 'reject with score.marks < level.gpa' do
          before do
            score.marks = 10
            level.gpa = 20
          end

          it 'returns empty' do
            student.send(:reject_scores, [score], level).should == []
          end
        end
      end

      context 'level.marks_limit_type = exact' do
        before { level.marks_limit_type = 'exact' }

        context 'not reject with score.marks = level.gpa' do
          before do
            score.marks = 20
            level.gpa = 20
          end

          it 'returns scores' do
            student.send(:reject_scores, [score], level).should == [score]
          end
        end

        context 'reject with score.marks != level.gpa' do
          before do
            score.marks = 21
            level.gpa = 20
          end

          it 'returns empty' do
            student.send(:reject_scores, [score], level).should == []
          end
        end
      end
    end

    context 'student.batch.gpa_enabled? is false' do
      before { student.batch.stub(:gpa_enabled?).and_return(false) }

      context 'level.marks_limit_type = upper' do
        before { level.marks_limit_type = 'upper' }

        context 'not reject with score.marks < level.marks' do
          before do
            score.marks = 10
            level.marks = 20
          end

          it 'returns scores' do
            student.send(:reject_scores, [score], level).should == [score]
          end
        end

        context 'reject with score.marks >= level.marks' do
          before do
            score.marks = 21
            level.marks = 20
          end

          it 'returns empty' do
            student.send(:reject_scores, [score], level).should == []
          end
        end
      end

      context 'level.marks_limit_type = lower' do
        before { level.marks_limit_type = 'lower' }

        context 'not reject with score.marks >= level.marks' do
          before do
            score.marks = 21
            level.marks = 20
          end

          it 'returns scores' do
            student.send(:reject_scores, [score], level).should == [score]
          end
        end

        context 'reject with score.marks < level.marks' do
          before do
            score.marks = 10
            level.marks = 20
          end

          it 'returns empty' do
            student.send(:reject_scores, [score], level).should == []
          end
        end
      end

      context 'level.marks_limit_type = exact' do
        before { level.marks_limit_type = 'exact' }

        context 'not reject with score.marks = level.marks' do
          before do
            score.marks = 20
            level.marks = 20
          end

          it 'returns scores' do
            student.send(:reject_scores, [score], level).should == [score]
          end
        end

        context 'reject with score.marks != level.marks' do
          before do
            score.marks = 21
            level.marks = 20
          end

          it 'returns empty' do
            student.send(:reject_scores, [score], level).should == []
          end
        end
      end
    end
  end

  describe '#check_scores_count_and_subject_count' do
    let(:student) { FactoryGirl.build(:student) }

    context 'subject_limit_type = upper' do
      let(:subject_limit_type) { 'upper' }

      context 'scores_count < subject_count' do
        let(:scores_count) { 10 }
        let(:subject_count) { 20 }

        it 'returns true' do
          student.send(:check_scores_count_and_subject_count, subject_limit_type, scores_count, subject_count).should be_true
        end
      end
    end

    context 'subject_limit_type = lower' do
      let(:subject_limit_type) { 'lower' }

      context 'scores_count >= subject_count' do
        let(:scores_count) { 21 }
        let(:subject_count) { 20 }

        it 'returns true' do
          student.send(:check_scores_count_and_subject_count, subject_limit_type, scores_count, subject_count).should be_true
        end
      end
    end

    context 'subject_limit_type = exact' do
      let(:subject_limit_type) { 'exact' }

      context 'scores_count = subject_count' do
        let(:scores_count) { 20 }
        let(:subject_count) { 20 }

        it 'returns true' do
          student.send(:check_scores_count_and_subject_count, subject_limit_type, scores_count, subject_count).should be_true
        end
      end
    end
  end
end
