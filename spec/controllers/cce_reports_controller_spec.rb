require 'spec_helper'

describe CceReportsController do
  before do
    @user = FactoryGirl.create(:admin_user)
    sign_in(@user)
  end

  describe 'GET index' do
    it 'is success' do
      get :index
      response.should be_success
    end
  end

  describe 'GET create_reports' do
    let(:courses) { [create(:course)] }

    it 'assigns courses' do
      Course.expects(:cce).returns(courses)
      get :create_reports
      assigns[:courses].should == courses
    end
  end

  describe 'POST create_reports' do
    let(:course_params) { { course: { batch_ids: batch_ids } } }

    context 'when batch_ids are present' do
      let(:batch_ids) { [1,2] }
      let(:errors) { ['errors'] }
      let(:notice) { 'notice' }

      before do
        Batch.expects(:create_reports).with(batch_ids).returns([notice, errors])
        post :create_reports, course_params
      end

      it 'renders error' do
        flash[:error].should == errors
      end

      it 'renders notice' do
        flash[:notice].should == notice
      end
    end

    context 'when batch_ids are not present' do
      let(:batch_ids) { [] }

      it 'renders errors' do
        post :create_reports, course_params
        flash[:notice].should == 'No batch selected'
      end
    end
  end

  describe 'GET student_wise_report' do
    let(:batches) { [create(:batch)] }

    it 'assigns batches' do
      Batch.expects(:cce).returns(batches)
      get :student_wise_report
      assigns[:batches].should == batches
    end
  end

  describe 'POST student_wise_report' do
    let(:course) { create(:course) }
    let(:batch) { course.batches.first }

    context 'always' do
      it 'assigns information' do
        post :student_wise_report, batch_id: batch.id
        assigns[:batch].should == batch
        assigns[:students].should == batch.students.all(order: 'first_name ASC')
      end

      it 'renders update' do
        page = mock('Page')
        controller.expects(:render).yields(page).at_least_once
        page.expects(:replace_html).times(3)
        post :student_wise_report, batch_id: batch.id
      end
    end

    context 'there are no students' do
      let(:student) { nil }

      before do
        controller.expects(:fetch_report).never
      end

      it 'does not fetch report' do
        post :student_wise_report, batch_id: batch.id
      end
    end

    context 'there are students' do
      let!(:student) { create(:student, batch_id: batch.id) }

      it 'fetchs report' do
        post :student_wise_report, batch_id: batch.id
        assigns[:report].should be_present
      end
    end
  end

  describe 'GET student_report' do
    let!(:student) { create(:student, batch_id: batch.id) }
    let(:course) { create(:course) }
    let(:batch) { course.batches.first }

    it 'assigns information' do
      get :student_report, student: student.id
      assigns[:student].should == student
      assigns[:batch].should == batch
      assigns[:report].should be_present
    end

    it 'renders update' do
      page = mock('Page')
      controller.expects(:render).yields(page).at_least_once
      page.expects(:replace_html)
      get :student_report, student: student.id
    end
  end

  describe 'GET student_report_pdf' do
    let(:type) { 'type' }
    let(:id) { '1' }
    let(:course) { create(:course) }
    let(:batch) { course.batches.first }
    let(:student) { create(:student) }
    let(:student_params) do
      {
        type: type,
        id: id,
        batch_id: batch.id
      }
    end

    before do
      CceReport.expects(:find_student).with(type, id).returns(student)
    end

    it 'assigns information and render pdf' do
      controller.expects(:render).with(pdf: "#{student.first_name}-CCE_Report")
      controller.expects(:render).with()
      get :student_report_pdf, student_params
      assigns[:batch].should == batch
      assigns[:student].should == student
      assigns[:type].should == type
      assigns[:report].should be_present
      student.batch_in_context.should == batch
    end
  end

  describe 'GET student_transcript' do
    let(:type) { 'type' }
    let(:id) { '1' }
    let(:course) { create(:course) }
    let(:batch) { course.batches.first }
    let(:student) { create(:student) }
    let(:student_params) do
      {
        type: type,
        id: id,
        batch_id: batch.id
      }
    end

    before do
      CceReport.expects(:find_student).with(type, id).returns(student)
    end

    context 'always' do
      it 'assigns information' do
        get :student_transcript, student_params
        assigns[:batch].should == batch
        assigns[:student].should == student
        assigns[:type].should == type
        assigns[:report].should be_present
        student.batch_in_context.should == batch
      end
    end

    context 'when request is not xhr' do
      it 'assign batches' do
        get :student_transcript, student_params
        assigns[:batches].should == student.all_batches.reverse
      end

      it 'does not render update' do
        page = mock('Page')
        controller.expects(:render).yields(page).at_least_once
        page.expects(:replace_html).never
        get :student_transcript, student_params
      end
    end

    context 'when request is xhr' do
      it 'does not assign batches' do
        xhr :get, :student_transcript, student_params
        assigns[:batches].should be_nil
      end

      it 'renders update' do
        page = mock('Page')
        controller.expects(:render).yields(page).at_least_once
        page.expects(:replace_html)
        xhr :get, :student_transcript, student_params
      end
    end
  end
end
