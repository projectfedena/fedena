require 'spec_helper'

describe ExamsController do
  before(:each) do
    @exam_group = Factory.create(:exam_group, :id => 1)
  end
  
  def mock_exam(stubs={})
    @mock_exam ||= mock_model(Exam, stubs)
  end

  describe "GET index" do # There is no index action
#    it "assigns all exams as @exams" do
#      Exam.stub(:find).with(:all).and_return([mock_exam])
#      get :index, :batch_id => 1
#      assigns[:exams].should == [mock_exam]
#    end
  end

  describe "GET show" do
    it "assigns the requested exam as @exam" do
      Exam.stub(:find).with("37").and_return(mock_exam)
      get :show, :id => "37", :exam_group_id => "1"
      assigns[:exam].should equal(mock_exam)
    end
  end

  describe "GET new" do
    it "assigns a new exam as @exam" do
      Exam.stub(:new).and_return(mock_exam)
      get :new, :batch_id => 1
      assigns[:exam].should equal(mock_exam)
    end
  end

  describe "GET edit" do
    it "assigns the requested exam as @exam" do
      Exam.stub(:find).with("37").and_return(mock_exam)
      get :edit, :id => "37"
      assigns[:exam].should equal(mock_exam)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created exam as @exam" do
        Exam.stub(:new).with({'these' => 'params'}).and_return(mock_exam(:save => true))
        post :create, :exam => Factory.attributes_for(:exam)
        assigns[:exam].should equal(mock_exam)
      end

      it "redirects to the created exam" do
        Exam.stub(:new).and_return(mock_exam(:save => true))
        post :create, :exam => {}
        response.should redirect_to(exam_url(mock_exam))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved exam as @exam" do
        Exam.stub(:new).with({'these' => 'params'}).and_return(mock_exam(:save => false))
        post :create, :exam => {:these => 'params'}
        assigns[:exam].should equal(mock_exam)
      end

      it "re-renders the 'new' template" do
        Exam.stub(:new).and_return(mock_exam(:save => false))
        post :create, :exam => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested exam" do
        Exam.should_receive(:find).with("37").and_return(mock_exam)
        mock_exam.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :exam => {:these => 'params'}
      end

      it "assigns the requested exam as @exam" do
        Exam.stub(:find).and_return(mock_exam(:update_attributes => true))
        put :update, :id => "1"
        assigns[:exam].should equal(mock_exam)
      end

      it "redirects to the exam" do
        Exam.stub(:find).and_return(mock_exam(:update_attributes => true))
        put :update, :id => "1"
        #response.should redirect_to(exam_url(mock_exam))
        response.should redirect_to(course_batches_exam_url(mock_exam))
      end
    end

    describe "with invalid params" do
      it "updates the requested exam" do
        Exam.should_receive(:find).with("37").and_return(mock_exam)
        mock_exam.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :exam => {:these => 'params'}
      end

      it "assigns the exam as @exam" do
        Exam.stub(:find).and_return(mock_exam(:update_attributes => false))
        put :update, :id => "1"
        assigns[:exam].should equal(mock_exam)
      end

      it "re-renders the 'edit' template" do
        Exam.stub(:find).and_return(mock_exam(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested exam" do
      Exam.should_receive(:find).with("37").and_return(mock_exam)
      mock_exam.should_receive(:destroy)
      delete :destroy, :id => "37", :batch_id => "1"
    end

    it "redirects to the exams list" do
      Exam.stub(:find).and_return(mock_exam(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(exams_url)
    end
  end

end
