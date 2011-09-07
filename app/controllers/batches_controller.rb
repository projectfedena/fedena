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

class BatchesController < ApplicationController
  before_filter :init_data,:except=>[:assign_tutor,:update_employees,:assign_employee,:remove_employee]
  filter_access_to :all
  
  def index
    @batches = @course.batches
  end

  def new
    @batch = @course.batches.build
  end

  def create
    @batch = @course.batches.build(params[:batch])

    if @batch.save
      flash[:notice] = 'Batch created successfully.'
      unless params[:import_subjects].nil?
        msg = []
        msg << "<ol>"
        course = @batch.course
        all_batches = Batch.find_all_by_course_id(course.id,:conditions=>'is_deleted = 0')
        all_batches.reject! {|b| b.is_deleted?}
        all_batches.reject! {|b| b.subjects.empty?}
        @previous_batch = all_batches[all_batches.size-2]
        subjects = Subject.find_all_by_batch_id(@previous_batch.id,:conditions=>'is_deleted=false')
        subjects.each do |subject|
          if subject.elective_group_id.nil?
            Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>@batch.id,:no_exams=>subject.no_exams,
              :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>subject.elective_group_id,:is_deleted=>false)
          else
            elect_group_exists = ElectiveGroup.find_by_name_and_batch_id(ElectiveGroup.find(subject.elective_group_id).name,@batch.id)
            if elect_group_exists.nil?
              elect_group = ElectiveGroup.create(:name=>ElectiveGroup.find(subject.elective_group_id).name,
                :batch_id=>@batch.id,:is_deleted=>false)
              Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>@batch.id,:no_exams=>subject.no_exams,
                :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>elect_group.id,:is_deleted=>false)
            else
              Subject.create(:name=>subject.name,:code=>subject.code,:batch_id=>@batch.id,:no_exams=>subject.no_exams,
                :max_weekly_classes=>subject.max_weekly_classes,:elective_group_id=>elect_group_exists.id,:is_deleted=>false)
            end
          end
          msg << "<li>#{subject.name}</li>"
        end
        msg << "</ol>"
      end
      flash[:subject_import] = msg unless msg.nil?

      err = ""
      unless params[:import_fees].nil?
        fee_msg = []
        fee_msg << "<ol>"
        course = @batch.course
        all_batches = Batch.find_all_by_course_id(course.id,:conditions=>'is_deleted = 0')
        all_batches.reject! {|b| b.is_deleted?}
        @previous_batch = all_batches[all_batches.size-2]
        categories = FinanceFeeCategory.find_all_by_batch_id(@previous_batch.id,:conditions=>'is_deleted=false and is_master=true')
        categories.each do |c|
          new_category = FinanceFeeCategory.new(:name=>c.name,:description=>c.description,:batch_id=>@batch.id,:is_deleted=>false,:is_master=>true)
          if new_category.save
            fee_msg << "<li>#{c.name}</li>"
            c.fee_particulars.each do |p|
              new_particular = FinanceFeeParticulars.new(:name=>p.name,:description=>p.description,:amount=>p.amount,:student_category_id=>p.student_category_id,\
                  :admission_no=>p.admission_no,:student_id=>p.student_id)
              new_particular.finance_fee_category_id = new_category.id
              unless new_particular.save
                err += "<li>Particular #{p.name} import failed.</li>"
              end
            end
          else
            err += "<li>Category #{c.name} import failed.</li>"
          end
        end
        fee_msg << "</ol>"
      end
      flash[:warn_notice] =  err unless err.empty?
      flash[:fees_import] =  fee_msg unless fee_msg.nil?
      
      redirect_to [@course, @batch]
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @batch.update_attributes(params[:batch])
      flash[:notice] = 'Updated batch details successfully.'
      redirect_to [@course, @batch]
    else
      flash[:notice] = "Please fill all feilds"
      redirect_to  edit_course_batch_path(@course, @batch)
    end
  end

  def show
    @students = @batch.students
  end

  def destroy
    if @batch.students.empty? and @batch.subjects.empty?
      @batch.inactivate
      flash[:notice] = 'Batch deleted successfully.'
      redirect_to @course
    else
      flash[:warn_notice] = '<p>Unable to delete Batch.Please delete all Students first.</p>' unless @batch.students.empty?
      flash[:warn_notice] = '<p>Unable to delete Batch.Please delete all Subjects first.</p>' unless @batch.subjects.empty?
      redirect_to [@course, @batch]
    end
  end

  def assign_tutor
    @batch = Batch.find_by_id(params[:id])
    @assigned_employee = @batch.employee_id.split(",") unless @batch.employee_id.nil?
    @departments = EmployeeDepartment.find(:all)
  end

  def update_employees
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    @batch = Batch.find_by_id(params[:batch_id])
    render :update do |page|
      page.replace_html 'employee-list', :partial => 'employee_list'
    end
  end

  def assign_employee
    @batch = Batch.find_by_id(params[:batch_id])
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    unless @batch.employee_id.blank?
    @assigned_emps = @batch.employee_id.split(',')
    else
    @assigned_emps = []
    end
    @assigned_emps.push(params[:id].to_s)
    @batch.update_attributes :employee_id => @assigned_emps.join(",")
    @assigned_employee = @assigned_emps.join(",")
    render :update do |page|
      page.replace_html 'employee-list', :partial => 'employee_list'
      page.replace_html 'tutor-list', :partial => 'assigned_tutor_list'
    end
  end

  def remove_employee
    @batch = Batch.find_by_id(params[:batch_id])
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    @assigned_emps = @batch.employee_id.split(',')
    @removed_emps = @assigned_emps.delete(params[:id].to_s)
    @assigned_emps = @assigned_emps.join(",")
    @batch.update_attributes :employee_id =>@assigned_emps
    render :update do |page|
      page.replace_html 'employee-list', :partial => 'employee_list'
      page.replace_html 'tutor-list', :partial => 'assigned_tutor_list'
    end
  end

  private
  def init_data
    @batch = Batch.find params[:id] if ['show', 'edit', 'update', 'destroy'].include? action_name
    @course = Course.find params[:course_id]
  end
end