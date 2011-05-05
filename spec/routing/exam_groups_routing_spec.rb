require 'spec_helper'

describe ExamGroupsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/batches/1/exam_groups" }.should \
        route_to(:controller => "exam_groups", :action => "index", :batch_id => "1")
    end

    it "recognizes and generates #new" do
      { :get => "/batches/1/exam_groups/new" }.should \
        route_to(:controller => "exam_groups", :action => "new", :batch_id => "1")
    end

    it "recognizes and generates #show" do
      { :get => "/batches/1/exam_groups/1" }.should \
        route_to(:controller => "exam_groups", :action => "show", :id => "1", :batch_id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/batches/1/exam_groups/1/edit" }.should \
        route_to(:controller => "exam_groups", :action => "edit", :id => "1", :batch_id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/batches/1/exam_groups" }.should \
        route_to(:controller => "exam_groups", :action => "create", :batch_id => "1")
    end

    it "recognizes and generates #update" do
      { :put => "/batches/1/exam_groups/1" }.should \
        route_to(:controller => "exam_groups", :action => "update", :id => "1", :batch_id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/batches/1/exam_groups/1" }.should \
        route_to(:controller => "exam_groups", :action => "destroy", :id => "1", :batch_id => "1")
    end
  end
end
