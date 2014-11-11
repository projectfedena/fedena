require 'spec_helper'

describe ObservationsController do

  describe "GET #show" do

    context "user is logged in" do

      before do
        @user = Factory.create(:admin_user)
        sign_in(@user)
        @observation = Observation.new
        @desc_indicator = DescriptiveIndicator.new
        @observation.stub(:descriptive_indicators) { @desc_indicator }
        Observation.stub(:find) { @observation }
        get :show, id: 1
      end

      it "sets variables" do
        assigns[:observation].should == @observation
        assigns[:descriptives].should == @desc_indicator
      end

      it "renders template" do
        response.should render_template("show")
      end
    end

    context "user is not logged in" do
      before do
        get :show, id: 1
      end

      it "redirects to home page" do
        response.should redirect_to(root_path)
      end
    end

  end

end
