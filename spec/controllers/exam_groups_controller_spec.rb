require 'spec_helper'

describe ExamGroupsController do

  before(:each) do
    @batch = Factory.create(:batch, :id => 1)
  end

  def mock_exam_group(stubs={})
    @mock_exam_group ||= mock_model(ExamGroup, stubs)
  end

  describe "GET index" do
    it "assigns all exam_groups as @exam_groups" do
      ExamGroup.stub(:find).with(:all).and_return([mock_exam_group])
      get :index, :batch_id => 1
      assigns[:exam_groups].should == [mock_exam_group]
    end
  end

  describe "GET show" do
    it "assigns the requested exam_group as @exam_group" do
      ExamGroup.stub(:find).with("37").and_return(mock_exam_goup)
      Batch.stub(:find).with("1").and_return(mock_batch)

      get :show, :id => "37", :batch_id => 1
      assigns[:exam_group].should equal(mock_exam_group)
    end
  end

  describe "GET new" do
    it "assigns a new exam_group as @exam_group" do
      ExamGroup.stub(:new).and_return(mock_exam_group)
      get :new, :batch_id => 1
      assigns[:exam_group].should equal(mock_exam_group)
    end
  end

  describe "GET edit" do
    it "assigns the requested exam_group as @exam_group" do
      ExamGroup.stub(:find).with("37").and_return(mock_exam_group)
      get :edit, :id => "37"
      assigns[:exam_group].should equal(mock_exam_group)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created exam_group as @exam_group" do
        ExamGroup.stub(:new).with({'these' => 'params'}).and_return(mock_exam_group(:save => true))
        post :create, :exam_group => {:these => 'params'}
        assigns[:exam_group].should equal(mock_exam_group)
      end

      it "redirects to the created exam_group" do
        ExamGroup.stub(:new).and_return(mock_exam_group(:save => true))
        post :create, :exam_group => {}
        response.should redirect_to(exam_group_url(mock_exam_group))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved exam_group as @exam_group" do
        ExamGroup.stub(:new).with({'these' => 'params'}).and_return(mock_exam_group(:save => false))
        post :create, :exam_group => {:these => 'params'}
        assigns[:exam_group].should equal(mock_exam_group)
      end

      it "re-renders the 'new' template" do
        ExamGroup.stub(:new).and_return(mock_exam_group(:save => false))
        post :create, :exam_group => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested exam_group" do
        ExamGroup.should_receive(:find).with("37").and_return(mock_exam_group)
        mock_exam_group.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :exam_group => {:these => 'params'}
      end

      it "assigns the requested exam_group as @exam_group" do
        ExamGroup.stub(:find).and_return(mock_exam_group(:update_attributes => true))
        put :update, :id => "1"
        assigns[:exam_group].should equal(mock_exam_group)
      end

      it "redirects to the exam_group" do
        ExamGroup.stub(:find).and_return(mock_exam_group(:update_attributes => true))
        put :update, :id => "1"
        #response.should redirect_to(exam_group_url(mock_exam_group))
        response.should redirect_to(batch_exam_group_url(mock_exam_group))
      end
    end

    describe "with invalid params" do
      it "updates the requested exam_group" do
        ExamGroup.should_receive(:find).with("37").and_return(mock_exam_group)
        mock_exam_group.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :exam_group => {:these => 'params'}
      end

      it "assigns the exam_group as @exam_group" do
        ExamGroup.stub(:find).and_return(mock_exam_group(:update_attributes => false))
        put :update, :id => "1"
        assigns[:exam_group].should equal(mock_exam_group)
      end

      it "re-renders the 'edit' template" do
        ExamGroup.stub(:find).and_return(mock_exam_group(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested exam_group" do
      ExamGroup.should_receive(:find).with("37").and_return(mock_exam_group)
      mock_exam_group.should_receive(:destroy)
      delete :destroy, :id => "37", :batch_id => "1"
    end

    it "redirects to the exam_groups list" do
      ExamGroup.stub(:find).and_return(mock_exam_group(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(exam_groups_url)
    end
  end

end
