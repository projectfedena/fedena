require 'spec_helper'

describe ExamsController do
  before do
    @user = FactoryGirl.create(:admin_user)

    @course     = FactoryGirl.create(:course)
    @batch      = FactoryGirl.create(:batch, :course => @course)
    @subject    = FactoryGirl.create(:subject, :batch => @batch)
    @exam_group = FactoryGirl.create(:exam_group, :batch => @batch)
    @exam       = FactoryGirl.create(:exam,
      :exam_group => @exam_group,
      :subject    => @subject)


    sign_in(@user)
  end

  describe 'GET #show' do
    before do
      get :show, :id => @exam.to_param, :exam_group_id => @exam_group.to_param
    end

    it 'renders the show template' do
      response.should render_template('show')
    end

    it 'assigns the requested exam_group as @exam_group' do
      assigns[:exam_group].should == @exam_group
    end

    it 'assigns the requested exam as @exam' do
      assigns(:exam).should == @exam
    end
  end

  describe 'GET #new' do
    context 'subject is in exam_group' do
      before do
        @course     = FactoryGirl.create(:course)
        @batch      = FactoryGirl.create(:batch, :course => @course)
        @subject    = FactoryGirl.create(:subject, :batch => @batch)
        @exam_group = FactoryGirl.create(:exam_group, :batch => @batch)
        @exam       = FactoryGirl.create(:exam,
          :exam_group => @exam_group,
          :subject    => FactoryGirl.create(:subject,
            :batch => FactoryGirl.create(:batch,
              :course => FactoryGirl.create(:course)
              )
            )
          )

        get :new, :exam_group_id => @exam_group.to_param
      end

      it 'renders the new template' do
        response.should render_template('new')
      end

      it 'assigns the requested exam_group as @exam_group' do
        assigns[:exam_group].should == @exam_group
      end

      it 'assigns a new exam as @exam' do
        assigns(:exam).should be_new_record
      end
    end

    context 'subject is not in exam_group' do
      before do
        get :new, :exam_group_id => @exam_group.to_param
      end

      it 'redirects to exam group' do
        response.should redirect_to([assigns(:batch), assigns(:exam_group)])
      end

      it 'sets flash[:notice]' do
        flash[:notice].should == "#{@controller.t('flash_msg4')}"
      end
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, :exam_group_id => @exam_group.to_param, :id => @exam.to_param
    end

    it 'assigns the requested exam_group as @exam_group' do
      assigns[:exam_group].should == @exam_group
    end

    it 'assigns the requested exam as @exam' do
      assigns(:exam).should == @exam
    end
  end

  # describe "POST create" do

  #   describe "with valid params" do
  #     it "assigns a newly created exam as @exam" do
  #       Exam.stub(:new).with({'these' => 'params'}).and_return(mock_exam(:save => true))
  #       post :create, :exam => Factory.attributes_for(:exam)
  #       assigns(:exam).should equal(mock_exam)
  #     end

  #     it "redirects to the created exam" do
  #       Exam.stub(:new).and_return(mock_exam(:save => true))
  #       post :create, :exam => {}
  #       response.should redirect_to(exam_url(mock_exam))
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns a newly created but unsaved exam as @exam" do
  #       Exam.stub(:new).with({'these' => 'params'}).and_return(mock_exam(:save => false))
  #       post :create, :exam => {:these => 'params'}
  #       assigns(:exam).should equal(mock_exam)
  #     end

  #     it "re-renders the 'new' template" do
  #       Exam.stub(:new).and_return(mock_exam(:save => false))
  #       post :create, :exam => {}
  #       response.should render_template('new')
  #     end
  #   end
  # end

  describe 'PUT #update' do
    describe 'succesful update' do
      before do
        Exam.stub(:find).with(@exam.to_param, :include => :exam_group).and_return(@exam)
        @exam.stub(:update_attributes).and_return(true)
        put :update, :id => @exam.to_param, :exam_group_id => @exam_group.to_param, :exam => { :these => 'params' }
      end

      it 'assigns the requested exam as @exam' do
        assigns(:exam).should == @exam
      end

      it 'sets flash[:notice]' do
        flash[:notice].should == "#{@controller.t('flash1')}"
      end

      it 'redirects to the exam' do
        response.should redirect_to([assigns(:exam_group), assigns(:exam)])
      end
    end

    describe 'failed update' do
      before do
        Exam.stub(:find).with(@exam.to_param, :include => :exam_group).and_return(@exam)
        @exam.stub(:update_attributes).and_return(false)
        put :update, :id => @exam.to_param, :exam_group_id => @exam_group.to_param, :exam => { :these => 'params' }
      end

      it 'assigns the requested exam as @exam' do
        assigns(:exam).should == @exam
      end

      it 're-renders the edit template' do
        response.should render_template('edit')
      end
    end
  end

  # describe "DELETE destroy" do
  #   it "destroys the requested exam" do
  #     Exam.should_receive(:find).with("37").and_return(mock_exam)
  #     mock_exam.should_receive(:destroy)
  #     delete :destroy, :id => "37", :batch_id => "1"
  #   end

  #   it "redirects to the exams list" do
  #     Exam.stub(:find).and_return(mock_exam(:destroy => true))
  #     delete :destroy, :id => "1"
  #     response.should redirect_to(exams_url)
  #   end
  # end

end
