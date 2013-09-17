require 'spec_helper'

describe ElectiveGroupsController do
  before do
    @user       = Factory.create(:admin_user)

    @elective_group = FactoryGirl.create(:elective_group)
    @batch      = FactoryGirl.create(:batch)
    @subject = FactoryGirl.create(:general_subject, :batch => @batch, :elective_group => @elective_group)

    sign_in(@user)
  end

  describe 'GET #index' do
    before do
      ElectiveGroup.stub(:for_batch).with(@batch.id, :include => :subjects).and_return([@elective_group])
      get :index, :batch_id => @batch.id
    end

    it 'renders the index template' do
      response.should render_template('index')
    end

    it 'assigns all ElectiveGroup as @elective_groups' do
      assigns(:elective_groups).should == [@elective_group]
    end
  end

  describe 'GET #new' do
    before do
      get :new, :batch_id => @batch
    end

    it 'renders the new template' do
      response.should render_template('new')
    end

    it 'assigns new record to @elective_group' do
      assigns(:elective_group).should be_new_record
    end
  end

  describe 'POST #create' do
    before do
      @elective_group = ElectiveGroup.new(:batch_id => @batch)
      ElectiveGroup.stub(:new).with({ 'these' => 'params' }).and_return(@elective_group)
    end

    context 'successful create' do
      before do
        ElectiveGroup.any_instance.expects(:save).returns(true)
        post :create, :batch_id => @batch, :elective_group => { 'these' => 'params' }
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "#{@controller.t('flash1')}"
      end

      it 'redirects to the batch_elective_groups_path' do
        response.should redirect_to(batch_elective_groups_path(assigns(:batch)))
      end
    end

    context 'failed create' do
      before do
        ElectiveGroup.any_instance.expects(:save).returns(false)
        post :create, :batch_id => @batch, :elective_group => { 'these' => 'params' }
      end

      it 'renders the new template' do
        response.should render_template('new')
      end
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, :id => @elective_group, :batch_id => @batch
    end

    it 'renders the edit template' do
      response.should render_template('edit')
    end

    it 'assigns @elective_group' do
      assigns(:elective_group).should == @elective_group
    end
  end

  describe 'PUT #update' do
    context 'successful update' do
      before do
        ElectiveGroup.any_instance.expects(:update_attributes).returns(true)
        put :update, :id => @elective_group, :batch_id => @batch, :elective_group => { 'these' => 'params' }
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "#{@controller.t('flash3')}"
      end

      it 'redirects to batch_elective_groups_path' do
        response.should redirect_to(batch_elective_groups_path(assigns(:batch)))
      end
    end

    context 'failed update' do
      before do
        ElectiveGroup.any_instance.expects(:update_attributes).returns(false)
        put :update, :id => @elective_group, :batch_id => @batch, :elective_group => { 'these' => 'params' }
      end

      it 'renders the edit template' do
        response.should render_template('edit')
      end

    end
  end

  describe 'DELETE #destroy' do
    it 'assigns flash[:notice]' do
      delete :destroy, :id => @elective_group, :batch_id => @batch
      flash[:notice].should == "#{@controller.t('flash2')}"
    end

    it 'redirects to the batch_elective_groups_path' do
      delete :destroy, :id => @elective_group, :batch_id => @batch
      response.should redirect_to(batch_elective_groups_path(assigns(:batch)))
    end
  end

  describe 'GET #show' do
    before do
      get :show, :batch_id => @batch, :id => @elective_group
    end

    it 'renders the edit template' do
      response.should render_template('show')
    end

    it 'assigns @electives' do
      assigns(:electives).should == [@subject]
    end
  end

end