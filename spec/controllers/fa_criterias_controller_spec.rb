require 'spec_helper'

describe FaCriteriasController do


  context "user is logged in" do
    before do
      @user = Factory.create(:admin_user)
      sign_in(@user)
      @fa_group = FactoryGirl.create(:fa_group)
      @fa_criteria = FactoryGirl.create(:fa_criteria, :fa_group => @fa_group)
    end

    describe "GET #index" do
      before do
        @fa_group.stub(:fa_criterias) { [@fa_criteria] }
        get :index, :fa_group_id => @fa_group
      end

      it "sets variables" do
        assigns[:fa_group].should == @fa_group
        assigns[:fa_criterias].should == [@fa_criteria]
      end

      it "renders template" do
        response.should render_template("index")
      end
    end

    describe "GET #show" do
      before do
        @desc_indicator = DescriptiveIndicator.new
        @fa_criteria.stub(:descriptive_indicators) { @desc_indicator }
        FaCriteria.stub(:find) { @fa_criteria }
        get :show, id: 1
      end

      it "sets variables" do
        assigns[:fa_criteria].should == @fa_criteria
        assigns[:descriptives].should == @desc_indicator
      end

      it "renders template" do
        response.should render_template("show")
      end
    end
  end

  context "user is not logged in" do
    %w(index show).each do |page|
      describe "GET ##{page}" do
        it "redirects to home page" do
          get page
          response.should redirect_to(root_path)
        end
      end
    end
  end

end
