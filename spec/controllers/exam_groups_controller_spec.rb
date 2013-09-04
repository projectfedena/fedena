require 'spec_helper'

describe ExamGroupsController do
  before do
    @user       = Factory.create(:admin_user)
    @course     = mock_model(Course)
    @exam_group = mock_model(ExamGroup)
    @batch      = mock_model(Batch, :exam_groups => [@exam_group], :course => @course)

    Batch.stub(:find).with('1', :include => :course).and_return(@batch)
    @cce_exam_category = mock_model(CceExamCategory)
    CceExamCategory.stub(:all).and_return([@cce_exam_category])
    @batch.stub(:cce_enabled?).and_return(true)

    sign_in(@user)
  end

  describe 'GET #index' do
    before do
      get :index, :batch_id => '1'
    end

    it 'renders the index template' do
      response.should render_template('index')
    end

    it 'assigns all exam_groups as @exam_groups' do
      assigns(:exam_groups).should == [@exam_group]
    end
  end

  describe 'GET #show' do
    before do
      ExamGroup.stub(:find).with('37', :include => :exams).and_return(@exam_group)
      get :show, :id => '37'
    end

    it 'renders the show template' do
      response.should render_template('show')
    end

    it 'assigns the requested exam_group as @exam_group' do
      assigns(:exam_group).should equal(@exam_group)
    end
  end

  describe 'GET #new' do
    before do
      get :new, :batch_id => '1'
    end

    it 'renders the new template' do
      response.should render_template('new')
    end

    it 'assigns @cce_exam_categories' do
      assigns(:cce_exam_categories).should == [@cce_exam_category]
    end
  end

  describe 'GET #edit' do
    before do
      ExamGroup.stub(:find).with('37').and_return(@exam_group)
      get :edit, :id => '37', :batch_id => '1'
    end

    it 'renders the edit template' do
      response.should render_template('edit')
    end

    it 'assigns @cce_exam_categories' do
      assigns(:cce_exam_categories).should == [@cce_exam_category]
    end
  end

  describe 'POST #create' do
    context 'exam_type is Grades' do
      before do
        @exam_group = ExamGroup.new(exam_type: 'Grades')
        ExamGroup.stub(:new).with({ 'these' => 'params' }).and_return(@exam_group)
      end

      context 'successful create' do
        before do
          @exam_group.stub(:save).and_return(true)
          post :create, :batch_id => '1', :exam_group => { 'these' => 'params' }
        end

        it 'assigns flash[:notice]' do
          flash[:notice].should == "#{@controller.t('flash1')}"
        end

        it 'redirects to the batch_exam_groups list' do
          response.should redirect_to(batch_exam_groups_path(assigns(:batch)))
        end
      end

      context 'failed create' do
        before do
          @exam_group.stub(:save).and_return(false)
          post :create, :batch_id => '1', :exam_group => { 'these' => 'params' }
        end

        it 'renders the new template' do
          response.should render_template('new')
        end

        it 'assigns @cce_exam_categories' do
          assigns(:cce_exam_categories).should == [@cce_exam_category]
        end
      end
    end

    context 'exam_type is not Grades' do
      before do
        @exam_group = ExamGroup.new(exam_type: 'Something')
        ExamGroup.stub(:new).and_return(@exam_group)
      end

      context 'missing maximum_marks in params' do
        before do
          post :create, :batch_id => '1', :exam_group => { :exams_attributes => [[{}, { :_delete => '0', :minimum_marks => '4' }]] }
        end

        it 'adds error to @exam_group' do
          assigns(:exam_group).errors[:base].should == "#{@controller.t('maxmarks_cant_be_blank')}"
        end

        it 'renders the new template' do
          response.should render_template('new')
        end

        it 'assigns @cce_exam_categories' do
          assigns(:cce_exam_categories).should == [@cce_exam_category]
        end
      end

      context 'missing minimum_marks in params' do
        before do
          post :create, :batch_id => '1', :exam_group => { :exams_attributes => [[{}, { :_delete => '0', :maximum_marks => '4' }]] }
        end

        it 'adds error to @exam_group' do
          assigns(:exam_group).errors[:base].should == "#{@controller.t('minmarks_cant_be_blank')}"
        end

        it 'renders the new template' do
          response.should render_template('new')
        end

        it 'assigns @cce_exam_categories' do
          assigns(:cce_exam_categories).should == [@cce_exam_category]
        end
      end
    end
  end

  describe 'PUT #update' do
    before do
      ExamGroup.stub(:find).with('37').and_return(@exam_group)
    end

    context 'successful update' do
      before do
        @exam_group.stub(:update_attributes).and_return(true)
        put :update, :id => '37', :batch_id => '1', :exam_group => { 'these' => 'params' }
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "#{@controller.t('flash2')}"
      end

      it 'redirects to exam_group detail' do
        response.should redirect_to([assigns(:batch), assigns(:exam_group)])
      end
    end

    context 'failed update' do
      before do
        @exam_group.stub(:update_attributes).and_return(false)
        put :update, :id => '37', :batch_id => '1', :exam_group => { 'these' => 'params' }
      end

      it 'renders the edit template' do
        response.should render_template('edit')
      end

      it 'assigns @cce_exam_categories' do
        assigns(:cce_exam_categories).should == [@cce_exam_category]
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      ExamGroup.stub(:find).with('37', :include => :exams).and_return(@exam_group)
      @exam_group.stub(:destroy).and_return(true)
    end

    it 'destroys the requested exam_group' do
      @exam_group.should_receive(:destroy)
      delete :destroy, :id => '37', :batch_id => '1'
    end

    it 'redirects to the batch_exam_groups list' do
      delete :destroy, :id => '37', :batch_id => '1'
      response.should redirect_to(batch_exam_groups_path(assigns(:batch)))
    end
  end
end
