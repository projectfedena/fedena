require 'spec_helper'

describe FaCriteriasController do

  describe "GET #index" do

    context "user is logged in" do

      before do
        @user = Factory.create(:admin_user)
        sign_in(@user)
        fa_group = double
        fa_group.stub(:fa_criterias) { [double] }
        FaGroup.stub(:find) { fa_group }
        get :index
      end

      it "sets variables" do
        assigns[:fa_group].should_not be_nil
        assigns[:fa_criterias].should_not be_nil
      end

      it "renders template" do
        response.should render_template("index")
      end

    end

  end

  describe "GET #show" do

    context "user is logged in" do

      before do
        @user = Factory.create(:admin_user)
        sign_in(@user)
        fa_criteria = double
        fa_criteria.stub(:descriptive_indicators) { [double] }
        FaCriteria.stub(:find) { fa_criteria }
        get :show, id: 1
      end

      it "sets variables" do
        assigns[:fa_criteria].should_not be_nil
        assigns[:descriptives].should_not be_nil
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
