#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class ClassTimingsController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def index
    @batches = Batch.active
    @class_timings = ClassTiming.find(:all,:conditions => { :batch_id => nil,:is_deleted=>false}, :order =>'start_time ASC')
  end

  def new
    @class_timing = ClassTiming.new
    @batch = Batch.find params[:id] if request.xhr? and params[:id]
    respond_to do |format|
      format.js { render :action => 'new' }
    end
  end

  def create
    @class_timing = ClassTiming.new(params[:class_timing])
    @batch = @class_timing.batch
    respond_to do |format|
      if @class_timing.save
        @class_timing.batch.nil? ?
          @class_timings = ClassTiming.find(:all,:conditions => { :batch_id => nil,:is_deleted=>false}, :order =>'start_time ASC') :
          @class_timings = ClassTiming.for_batch(@class_timing.batch_id)
        #  flash[:notice] = 'Class timing was successfully created.'
        format.html { redirect_to class_timing_url(@class_timing) }
        format.js { render :action => 'create' }
      else
        @error = true
        format.html { render :action => "new" }
        format.js { render :action => 'create' }
      end
    end
  end

  def edit
    @class_timing = ClassTiming.find(params[:id])
    respond_to do |format|
      format.html { }
      format.js { render :action => 'edit' }
    end
  end

  def update
    @class_timing = ClassTiming.find params[:id]
    respond_to do |format|
      if @class_timing.update_attributes(params[:class_timing])
        @class_timing.batch.nil? ?
          @class_timings = ClassTiming.find(:all,:conditions => { :batch_id => nil}, :order =>'start_time ASC') :
          @class_timings = ClassTiming.for_batch(@class_timing.batch_id)
        #     flash[:notice] = 'Class timing updated successfully.'
        format.html { redirect_to class_timing_url(@class_timing) }
        format.js { render :action => 'update' }
      else
        @error = true
        format.html { render :action => "new" }
        format.js { render :action => 'create' }
      end
    end
  end

  def show
    @batch = nil
    if params[:batch_id] == ''
      @class_timings = ClassTiming.find(:all, :conditions=>["batch_id is null and is_deleted = false"])
    else
      @class_timings = ClassTiming.active_for_batch(params[:batch_id])
      @batch = Batch.find params[:batch_id] unless params[:batch_id] == ''
    end
    respond_to do |format|
      format.js { render :action => 'show' }
    end
  end

  def destroy
    @class_timing = ClassTiming.find params[:id]
    @class_timing.update_attribute(:is_deleted,true)
  end

end
