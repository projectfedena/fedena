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

class CoursesController < ApplicationController
  before_filter :login_required
  before_filter :find_course, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all
  
  def index
    @courses = Course.active
  end

  def new
    @course = Course.new
  end

  def manage_course
    @courses = Course.active
  end

  def manage_batches

  end

  def update_batch
    @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })

    render(:update) do |page|
      page.replace_html 'update_batch', :partial=>'update_batch'
    end

  end

  def create
    @course = Course.new params[:course]
    if @course.save
      flash[:notice] = "#{t('flash1')}"
      redirect_to :action=>'manage_course'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @course.update_attributes(params[:course])
      flash[:notice] = "#{t('flash2')}"
      redirect_to :action=>'manage_course'
    else
      render 'edit'
    end
  end

  def destroy
    if @course.batches.active.empty?
      @course.inactivate
       flash[:notice]="#{t('flash3')}"
      redirect_to :action=>'manage_course'
    else
      flash[:warn_notice]="<p>#{t('courses.flash4')}</p>"
      redirect_to :action=>'manage_course'
    end
  
  end

  def show
    @batches = @course.batches.active
  end

  private
  def find_course
    @course = Course.find params[:id]
  end


  #  To be used once the new exam system is completed.
  #
  #  def email
  #    @course = Course.find(params[:id])
  #    if request.post?
  #      recipient_list = []
  #      case params['email']['recipients']
  #      when 'Students'             then recipient_list << @course.student_email_list
  #      when 'Guardians'            then recipient_list << @course.guardian_email_list
  #      when 'Students & Guardians' then recipient_list += @course.student_email_list + @course.guardian_email_list
  #      end
  #
  #      unless recipient_list.empty?
  #        recipients = recipient_list.join(', ')
  #        FedenaMailer::deliver_email(recipients, params[:email][:subject], params[:email][:message])
  #        flash[:notice] = "Mail sent to #{recipients}"
  #        redirect_to :controller => 'user', :action => 'dashboard'
  #      end
  #    end
  #  end
  #
  #  def send_sms
  #    @course = Course.find params[:id], :include => [:students]
  #    if request.post?
  #      sms = SmsManager.new params[:message], ['9656001824']
  #      sms.send_sms
  #      flash[:notice] = 'Text messages sent successfully!'
  #    end
  #  end

end