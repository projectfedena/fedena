require 'spec_helper'

describe ElectiveGroupsController do
  before do
    @user       = Factory.create(:admin_user)
    @course     = mock_model(Course)
    @elective_group = mock_model(ElectiveGroup, :id => '20')
    @subject = mock_model(Subject)
    @batch      = mock_model(Batch, :id => '1', :course => @course, :elective_groups => @elective_group)

    Batch.stub(:find).with(@batch.id, :include => :course).and_return(@batch)

    sign_in(@user)
  end

  describe 'GET #index' do
    before do
      ElectiveGroup.stub(:for_batch).with('1', :include => :subjects).and_return([@elective_group])
      get :index, :batch_id => '1'
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
      @batch.elective_groups.stub(:build).and_return(@elective_group)
      get :new, :batch_id => '1'
    end

    it 'renders the new template' do
      response.should render_template('new')
    end

    it 'assigns new record to @elective_group' do
      assigns(:elective_group).should == @elective_group
    end
  end

  describe 'POST #create' do
    before do
      @elective_group = ElectiveGroup.new(:batch_id => '1')
      ElectiveGroup.stub(:new).with({ 'these' => 'params' }).and_return(@elective_group)
    end

    context 'successful create' do
      before do
        @elective_group.stub(:save).and_return(true)
        post :create, :batch_id => '1', :elective_group => { 'these' => 'params' }
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
        @elective_group.stub(:save).and_return(false)
        post :create, :batch_id => '1', :elective_group => { 'these' => 'params' }
      end

      it 'renders the new template' do
        response.should render_template('new')
      end
    end
  end

  describe 'GET #edit' do
    before do
      ElectiveGroup.stub(:find).with('20').and_return(@elective_group)
      get :edit, :id => '20', :batch_id => '1'
    end

    it 'renders the edit template' do
      response.should render_template('edit')
    end

    it 'assigns @elective_group' do
      assigns(:elective_group).should == @elective_group
    end
  end

  describe 'PUT #update' do
    before do
      ElectiveGroup.stub(:find).with('20').and_return(@elective_group)
    end

    context 'successful update' do
      before do
        @elective_group.stub(:update_attributes).and_return(true)
        put :update, :id => '20', :batch_id => '1', :elective_group => { 'these' => 'params' }
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
        @elective_group.stub(:update_attributes).and_return(false)
        put :update, :id => '20', :batch_id => '1', :elective_group => { 'these' => 'params' }
      end

      it 'renders the edit template' do
        response.should render_template('edit')
      end

    end
  end

  describe 'DELETE #destroy' do
    before do
      ElectiveGroup.stub(:find).with('20').and_return(@elective_group)
      @elective_group.stub(:inactivate)
    end

    it 'inactivate the requested elective_group' do
      @elective_group.should_receive(:inactivate)
      delete :destroy, :id => '20', :batch_id => '1'
    end

    it 'assigns flash[:notice]' do
      delete :destroy, :id => '20', :batch_id => '1'
      flash[:notice].should == "#{@controller.t('flash2')}"
    end

    it 'redirects to the batch_elective_groups_path' do
      delete :destroy, :id => '20', :batch_id => '1'
      response.should redirect_to(batch_elective_groups_path(assigns(:batch)))
    end
  end

  describe 'GET #show' do
    before do
      ElectiveGroup.stub(:find).with('20').and_return(@elective_group)
      Subject.stub(:find_all_by_batch_id_and_elective_group_id).with('1','20', :conditions=>{:is_deleted => false}).and_return(@subject)
      get :show, :batch_id => '1', :id => '20'
    end

    it 'renders the edit template' do
      response.should render_template('show')
    end

    it 'assigns @electives' do
      assigns(:electives).should == @subject
    end
  end

end