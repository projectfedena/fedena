require 'spec_helper'

describe ExamsController do

  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/exam_groups/1/exams" }.should \
        route_to(:controller => "exams", :action => "index", :exam_group_id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/exam_groups/1/exams/new" }.should \
        route_to(:controller => "exams", :action => "new", :exam_group_id => "1")
    end

    it "recognizes and generates #show" do
      { :get => "/exam_groups/1/exams/1" }.should \
        route_to(:controller => "exams", :action => "show", :id => "1", :exam_group_id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/exam_groups/1/exams/1/edit" }.should \
        route_to(:controller => "exams", :action => "edit", :id => "1", :exam_group_id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/exam_groups/1/exams" }.should \
        route_to(:controller => "exams", :action => "create", :exam_group_id => "1")
    end

    it "recognizes and generates #update" do
      { :put => "/exam_groups/1/exams/1" }.should \
        route_to(:controller => "exams", :action => "update", :id => "1", :exam_group_id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/exam_groups/1/exams/1" }.should \
        route_to(:controller => "exams", :action => "destroy", :id => "1", :exam_group_id => "1")
    end
  end
end
