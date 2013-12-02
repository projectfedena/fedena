require 'spec_helper'

describe EmployeeController do
  before do
    controller.stub!(:configuration_settings_for_hr)
    @employee = FactoryGirl.build(:employee)
    @emp_category = FactoryGirl.build(:general_emp_category)
    @user = FactoryGirl.create(:admin_user)
    sign_in(@user)
  end

  describe '#add_category' do
    before do
      EmployeeCategory.stub(:all).and_return(@emp_category)
      EmployeeCategory.stub(:new).and_return(@emp_category)
    end

    context 'successful create' do
      before do
        EmployeeCategory.any_instance.expects(:save).returns(true)
        post :add_category
      end

      it 'assigns @categories' do
        assigns(:categories).should == @emp_category
      end

      it 'assigns @inactive_categories' do
        assigns(:inactive_categories).should == @emp_category
      end

      it 'assigns @category' do
        assigns(:category).should == @emp_category
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "#{@controller.t('flash1')}"
      end

      it 'redirects to action add_category' do
        response.should redirect_to(:controller => 'employee', :action => 'add_category')
      end
    end
  end
end