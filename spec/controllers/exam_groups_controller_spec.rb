require 'spec_helper'

describe ExamGroupsController do
  before do
    @user       = Factory.create(:admin_user)

    @cce_exam_category = FactoryGirl.create(:cce_exam_category)
    @exam_group = FactoryGirl.create(:exam_group, :cce_exam_category => @cce_exam_category)
    @batch      = FactoryGirl.create(:batch, :exam_groups => [@exam_group])
    Batch.stub(:find).with(@batch, :include => :course).and_return(@batch)
    @batch.stub(:cce_enabled?).and_return(true)

    sign_in(@user)
  end

  describe 'GET #index' do
    before do
      get :index, :batch_id => @batch
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
      get :show, :id => @exam_group, :batch_id => @batch
    end

    it 'renders the show template' do
      response.should render_template('show')
    end

    it 'assigns the requested exam_group as @exam_group' do
      assigns(:exam_group).should == @exam_group
    end
  end

  describe 'GET #new' do
    before do
      get :new, :batch_id => @batch
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
      get :edit, :id => @exam_group, :batch_id => @batch
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
        @exam_group = ExamGroup.new(:exam_type => 'Grades')
        ExamGroup.stub(:new).with({ 'these' => 'params' }).and_return(@exam_group)
      end

      context 'successful create' do
        before do
          ExamGroup.any_instance.expects(:save).returns(true)
          post :create, :batch_id => @batch, :exam_group => { 'these' => 'params' }
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
          ExamGroup.any_instance.expects(:save).returns(false)
          post :create, :batch_id => @batch, :exam_group => { 'these' => 'params' }
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
        @exam_group = ExamGroup.new(:exam_type => 'Something')
        ExamGroup.stub(:new).and_return(@exam_group)
      end

      context 'missing maximum_marks in params' do
        before do
          post :create, :batch_id => @batch, :exam_group => { :exams_attributes => [[{}, { :_delete => '0', :minimum_marks => '4' }]] }
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
          post :create, :batch_id => @batch, :exam_group => { :exams_attributes => [[{}, { :_delete => '0', :maximum_marks => '4' }]] }
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
    context 'successful update' do
      before do
        ExamGroup.any_instance.expects(:update_attributes).returns(true)
        put :update, :id => @exam_group, :batch_id => @batch, :exam_group => { 'these' => 'params' }
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
        ExamGroup.any_instance.expects(:update_attributes).returns(false)
        put :update, :id => @exam_group, :batch_id => @batch, :exam_group => { 'these' => 'params' }
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
      ExamGroup.stub(:find).with(@exam_group, :include => :exams).and_return(@exam_group)
    end

    it 'destroys the requested exam_group' do
      @exam_group.should_receive(:destroy)
      delete :destroy, :id => @exam_group, :batch_id => @batch
    end

    it 'redirects to the batch_exam_groups list' do
      delete :destroy, :id => @exam_group, :batch_id => @batch
      response.should redirect_to(batch_exam_groups_path(assigns(:batch)))
    end
  end
end
