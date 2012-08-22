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

class StudentController < ApplicationController
  filter_access_to :all
  before_filter :login_required
  before_filter :protect_other_student_data, :except =>[:show]
    
  before_filter :find_student, :only => [
    :academic_report, :academic_report_all, :admission3, :change_to_former,
    :delete, :edit, :add_guardian, :email, :remove, :reports, :profile,
    :guardians, :academic_pdf,:show_previous_details,:fees,:fee_details
  ]

  
  def academic_report_all
    @user = current_user
    @prev_student = @student.previous_student
    @next_student = @student.next_student
    @course = @student.course
    @examtypes = ExaminationType.find( ( @course.examinations.collect { |x| x.examination_type_id } ).uniq )
    
    @graph = open_flash_chart_object(965, 350, "/student/graph_for_academic_report?course=#{@course.id}&student=#{@student.id}")
    @graph2 = open_flash_chart_object(965, 350, "/student/graph_for_annual_academic_report?course=#{@course.id}&student=#{@student.id}")
  end

  def admission1
    @student = Student.new(params[:student])
    @selected_value = Configuration.default_country 
    @application_sms_enabled = SmsSetting.find_by_settings_key("ApplicationEnabled")
    @last_admitted_student = Student.find(:last)
    @config = Configuration.find_by_config_key('AdmissionNumberAutoIncrement')
    @categories = StudentCategory.active
    if request.post?
      if @config.config_value.to_i == 1
        @exist = Student.find_by_admission_no(params[:student][:admission_no])
        if @exist.nil?
          @status = @student.save
        else
          @last_admitted_student = Student.find(:last)
          @student.admission_no = @last_admitted_student.admission_no.next
          @status = @student.save
        end
      else
        @status = @student.save
      end
      if @status
        sms_setting = SmsSetting.new()
        if sms_setting.application_sms_active and @student.is_sms_enabled
          recipients = []
          message = "#{t('student_admission_done')} #{@student.admission_no} #{t('password_is')} #{@student.admission_no}123"
          if sms_setting.student_sms_active
            recipients.push @student.phone2 unless @student.phone2.blank?
          end
          unless recipients.empty?
            Delayed::Job.enqueue(SmsManager.new(message,recipients))
          end
        end
        flash[:notice] = "#{t('flash8')}"
        redirect_to :controller => "student", :action => "admission2", :id => @student.id
      end
    end
  end

  def admission2
    @student = Student.find params[:id], :include => [:guardians]
    @guardian = Guardian.new params[:guardian]
    if request.post? and @guardian.save
      redirect_to :controller => "student", :action => "admission2", :id => @student.id
    end
  end

  def admission3
    @student = Student.find(params[:id])
    @parents = @student.guardians
    if @parents.empty?
      redirect_to :controller => "student", :action => "previous_data", :id => @student.id
    end
    return if params[:immediate_contact].nil?
    if request.post?
      sms_setting = SmsSetting.new()
      @student = Student.update(@student.id, :immediate_contact_id => params[:immediate_contact][:contact])
      if sms_setting.application_sms_active and @student.is_sms_enabled
        recipients = []
        message = "#{t('student_admission_done')}  #{@student.admission_no} #{t('password_is')} #{@student.admission_no}123"
        if sms_setting.parent_sms_active
          guardian = Guardian.find(@student.immediate_contact_id)
          recipients.push guardian.mobile_phone unless guardian.mobile_phone.nil?
        end
        unless recipients.empty?
          Delayed::Job.enqueue(SmsManager.new(message,recipients))
        end
      end
      redirect_to :action => "previous_data", :id => @student.id
    end
  end

  def admission3_1
    @student = Student.find(params[:id])
    @parents = @student.guardians
    if @parents.empty?
      redirect_to :controller => "student", :action => "admission4", :id => @student.id
    end
    return if params[:immediate_contact].nil?
    if request.post?
      sms_setting = SmsSetting.new()
      @student = Student.update(@student.id, :immediate_contact_id => params[:immediate_contact][:contact])
      if sms_setting.application_sms_active and @student.is_sms_enabled
        recipients = []
        message = "#{t('student_admission_done')}   #{@student.admission_no} #{t('password_is')}#{@student.admission_no}123"
        if sms_setting.parent_sms_active
          guardian = Guardian.find(@student.immediate_contact_id)
          recipients.push guardian.mobile_phone unless guardian.mobile_phone.nil?
        end
        unless recipients.empty?
          Delayed::Job.enqueue(SmsManager.new(message,recipients))
        end
      end
      redirect_to :action => "profile", :id => @student.id
    end
  end

  def previous_data
    @student = Student.find(params[:id])
    @previous_data = StudentPreviousData.new params[:student_previous_details]
    @previous_subject = StudentPreviousSubjectMark.find_all_by_student_id(@student)
    if request.post?
      @previous_data.save
      redirect_to :action => "admission4", :id => @student.id
    else
      return
    end
  end

  def previous_data_edit
    @student = Student.find(params[:id])
    @previous_data = StudentPreviousData.find_by_student_id(params[:id])
    @previous_subject = StudentPreviousSubjectMark.find_all_by_student_id(@student)
    if request.post?
      @previous_data.update_attributes(params[:previous_data])
      redirect_to :action => "show_previous_details", :id => @student.id
    end
  end

  def previous_subject
    @student = Student.find(params[:id])
    render(:update) do |page|
      page.replace_html 'subject', :partial=>"previous_subject"
    end
  end

  def save_previous_subject
    @previous_subject = StudentPreviousSubjectMark.new params[:student_previous_subject_details]
    @previous_subject.save
    #@all_previous_subject = StudentPreviousSubjectMark.find(:all,:conditions=>"student_id = #{@previous_subject.student_id}")
  end

  def delete_previous_subject
    @previous_subject = StudentPreviousSubjectMark.find(params[:id])
    @student =Student.find(@previous_subject.student_id)
    if@previous_subject.delete
      @previous_subject=StudentPreviousSubjectMark.find_all_by_student_id(@student.id)
    end
    #@all_previous_subject = StudentPreviousSubjectMark.find(:all,:conditions=>"student_id = #{@previous_subject.student_id}")
  end

  def admission4
    @student = Student.find(params[:id])
    @additional_fields = StudentAdditionalField.find(:all, :conditions=> "status = true")
    if @additional_fields.empty?
      flash[:notice] = "#{t('flash9')} #{@student.first_name} #{@student.last_name}."
      redirect_to :controller => "student", :action => "profile", :id => @student.id
    end
    if request.post?
      params[:student_additional_details].each_pair do |k, v|
        StudentAdditionalDetail.create(:student_id => params[:id],
          :additional_field_id => k,:additional_info => v['additional_info'])
      end
      flash[:notice] = "#{t('flash9')} #{@student.first_name} #{@student.last_name}."
      redirect_to :controller => "student", :action => "profile", :id => @student.id
    end
  end

  def edit_admission4
    @student = Student.find(params[:id])
    @additional_fields = StudentAdditionalField.find(:all, :conditions=> "status = true")
    @additional_details = StudentAdditionalDetail.find_all_by_student_id(@student)
    
    if @additional_details.empty?
      redirect_to :controller => "student",:action => "admission4" , :id => @student.id
    end
    if request.post?
   
      params[:student_additional_details].each_pair do |k, v|
        row_id=StudentAdditionalDetail.find_by_student_id_and_additional_field_id(@student.id,k)
        unless row_id.nil?
          additional_detail = StudentAdditionalDetail.find_by_student_id_and_additional_field_id(@student.id,k)
          StudentAdditionalDetail.update(additional_detail.id,:additional_info => v['additional_info'])
        else
          StudentAdditionalDetail.create(:student_id=>@student.id,:additional_field_id=>k,:additional_info=>v['additional_info'])
        end
      end
      flash[:notice] = "#{t('student_text')} #{@student.first_name} #{t('flash2')}"
      redirect_to :action => "profile", :id => @student.id
    end
  end
  def add_additional_details
    @additional_details = StudentAdditionalField.find(:all)
    @additional_field = StudentAdditionalField.new(params[:additional_field])
    if request.post? and @additional_field.save
      flash[:notice] = "#{t('flash1')}"
      redirect_to :controller => "student", :action => "add_additional_details"
    end
  end

  def edit_additional_details
    @additional_details = StudentAdditionalField.find(params[:id])
    if request.post? and @additional_details.update_attributes(params[:additional_details])
      flash[:notice] = "#{t('flash2')}"
      redirect_to :action => "add_additional_details"
    end
  end

  def delete_additional_details
    students = StudentAdditionalDetail.find(:all ,:conditions=>"additional_field_id = #{params[:id]}")
    if students.blank?
      StudentAdditionalField.find(params[:id]).destroy
      @additional_details = StudentAdditionalField.find(:all)
      flash[:notice]="#{t('flash13')}"
      redirect_to :action => "add_additional_details"
    else
      flash[:notice]="#{t('flash14')}"
      redirect_to :action => "add_additional_details"
    end
  end

  def change_to_former
    @dependency = @student.former_dependency
    if request.post?
      @student.archive_student(params[:remove][:status_description])
      render :update do |page|
        page.replace_html 'remove-student', :partial => 'student_tc_generate'
      end
    end
  end

  def generate_tc_pdf
    @student = ArchivedStudent.find_by_admission_no(params[:id])
    @father = ArchivedGuardian.find_by_ward_id(@student.id, :conditions=>"relation = 'father'")
    @mother = ArchivedGuardian.find_by_ward_id(@student.id, :conditions=>"relation = 'mother'")
    @immediate_contact = ArchivedGuardian.find_by_ward_id(@student.immediate_contact_id) \
      unless @student.immediate_contact_id.nil? or @student.immediate_contact_id == ''
    render :pdf=>'generate_tc_pdf'
    #        respond_to do |format|
    #            format.pdf { render :layout => false }
    #        end
  end

  def generate_all_tc_pdf
    @ids = params[:stud]
    @students = @ids.map { |st_id| ArchivedStudent.find(st_id) }
    
    render :pdf=>'generate_all_tc_pdf'
  end

  def destroy
    student = Student.find(params[:id])
    unless student.check_dependency
      student.destroy
      flash[:notice] = "#{t('flash10')}. #{student.admission_no}."
      redirect_to :controller => 'user', :action => 'dashboard'
    else
      flash[:warn_notice] = "#{t('flash15')}"
      redirect_to  :action => 'remove', :id=>student.id
    end
  end

  def edit
    @student = Student.find(params[:id])
    @student_user = @student.user
    @student_categories = StudentCategory.active
    @batches = Batch.active
    @application_sms_enabled = SmsSetting.find_by_settings_key("ApplicationEnabled")

    if request.post?
      unless params[:student][:image_file].blank?
        unless params[:student][:image_file].size.to_f > 280000
          if @student.update_attributes(params[:student])
            unless @student.changed.include?('admission_no')
              @student_user.update_attributes(:username=> @student.admission_no,:password => "#{@student.admission_no.to_s}123",:first_name=> @student.first_name , :last_name=> @student.last_name, :email=> @student.email, :role=>'Student')
            else
              @student_user.update_attributes(:username=> @student.admission_no,:first_name=> @student.first_name , :last_name=> @student.last_name, :email=> @student.email, :role=>'Student')
            end
            flash[:notice] = "#{t('flash3')}"
            redirect_to :controller => "student", :action => "profile", :id => @student.id
          end
        else
          flash[:notice] = "#{t('flash_msg11')}"
          redirect_to :controller => "student", :action => "edit", :id => @student.id
        end
      else
        if @student.update_attributes(params[:student])
          unless @student.changed.include?('admission_no')
            @student_user.update_attributes(:username=> @student.admission_no,:password => "#{@student.admission_no.to_s}123",:first_name=> @student.first_name , :last_name=> @student.last_name, :email=> @student.email, :role=>'Student')
          else
            @student_user.update_attributes(:username=> @student.admission_no,:first_name=> @student.first_name , :last_name=> @student.last_name, :email=> @student.email, :role=>'Student')
          end
          flash[:notice] = "#{t('flash3')}"
          redirect_to :controller => "student", :action => "profile", :id => @student.id
        end
      end
    end
  end


  def edit_guardian
    @parent = Guardian.find(params[:id])
    @student = Student.find(@parent.ward_id)
    @countries = Country.all
    if request.post? and @parent.update_attributes(params[:parent_detail])
      if @parent.email.blank?
        @parent.email= "noreplyp#{@parent.ward.admission_no}@fedena.com"
        @parent.save
      end
      if @parent.id  == @student.immediate_contact_id
        unless @parent.user.nil?
          User.update(@parent.user.id, :first_name=> @parent.first_name, :last_name=> @parent.last_name, :email=> @parent.email, :role =>"Parent")
        else
          @parent.create_guardian_user(@student)
        end
      end
      flash[:notice] = "#{t('student.flash4')}"
      redirect_to :controller => "student", :action => "guardians", :id => @student.id
    end
  end

  def email
    sender = current_user.email
    if request.post?
      recipient_list = []
      case params['email']['recipients']
      when 'Student'
        recipient_list << @student.email
      when 'Guardian'
        recipient_list << @student.immediate_contact.email unless @student.immediate_contact.nil?
      when 'Student & Guardian'
        recipient_list << @student.email
        recipient_list << @student.immediate_contact.email unless @student.immediate_contact.nil?
      end
      FedenaMailer::deliver_email(sender, recipient_list, params['email']['subject'], params['email']['message'])
      flash[:notice] = "#{t('flash12')} #{recipient_list.join(', ')}"
      redirect_to :controller => 'student', :action => 'profile', :id => @student.id
    end
  end

  def exam_report
    @user = current_user
    @examtype = ExaminationType.find(params[:exam])
    @course = Course.find(params[:course])
    @student = Student.find(params[:student]) if params[:student]
    @student ||= @course.students.first
    @prev_student = @student.previous_student
    @next_student = @student.next_student
    @subjects = @course.subjects_with_exams
    @results = {}
    @subjects.each do |s|
      exam = Examination.find_by_subject_id_and_examination_type_id(s, @examtype)
      res = ExaminationResult.find_by_examination_id_and_student_id(exam, @student)
      @results[s.id.to_s] = { 'subject' => s, 'result' => res } unless res.nil?
    end
    @graph = open_flash_chart_object(770, 350, "/student/graph_for_exam_report?course=#{@course.id}&examtype=#{@examtype.id}&student=#{@student.id}")
  end

  def update_student_result_for_examtype
    @student = Student.find(params[:student])
    @examtype = ExaminationType.find(params[:examtype])
    @course = @student.course
    @prev_student = @student.previous_student
    @next_student = @student.next_student
    @subjects = @course.subjects_with_exams
    @results = {}
    @subjects.each do |s|
      exam = Examination.find_by_subject_id_and_examination_type_id(s, @examtype)
      res = ExaminationResult.find_by_examination_id_and_student_id(exam, @student)
      @results[s.id.to_s] = { 'subject' => s, 'result' => res } unless res.nil?
    end
    @graph = open_flash_chart_object(770, 350, "/exam/graph_for_student_exam_result?course=#{@course.id}&examtype=#{@examtype.id}&student=#{@student.id}")
    render(:update) { |page| page.replace_html 'exam-results', :partial => 'student_result_for_examtype' }
  end

  def previous_years_marks_overview
    @student = Student.find(params[:student])
    @all_courses = @student.all_courses
    @graph = open_flash_chart_object(770, 350, "/student/graph_for_previous_years_marks_overview?student=#{params[:student]}&graphtype=#{params[:graphtype]}")
  end

  def reports
    @batch = @student.batch
    @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
    @normal_subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>"no_exams = false AND elective_group_id IS NULL AND is_deleted = false")
    @student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>{:batch_id=>@batch.id})
    @elective_subjects = []
    @student_electives.each do |e|
      @elective_subjects.push Subject.find(e.subject_id)
    end
    @subjects = @normal_subjects+@elective_subjects
    @exam_groups = @batch.exam_groups
    @exam_groups.reject!{|e| e.result_published==false}
    @old_batches = @student.graduated_batches
  end

  def search_ajax
    if params[:option] == "active"
      if params[:query].length>= 3
        @students = Student.find(:all,
          :conditions => ["first_name LIKE ? OR middle_name LIKE ? OR last_name LIKE ?
                            OR admission_no = ? OR (concat(first_name, \" \", last_name) LIKE ? ) ",
            "#{params[:query]}%","#{params[:query]}%","#{params[:query]}%",
            "#{params[:query]}", "#{params[:query]}" ],
          :order => "batch_id asc,first_name asc",:include =>  [{:batch=>:course}]) unless params[:query] == ''
      else
        @students = Student.find(:all,
          :conditions => ["admission_no = ? " , params[:query]],
          :order => "batch_id asc,first_name asc",:include =>  [{:batch=>:course}]) unless params[:query] == ''
      end
      render :layout => false
    else
      if params[:query].length>= 3
        @archived_students = ArchivedStudent.find(:all,
          :conditions => ["first_name LIKE ? OR middle_name LIKE ? OR last_name LIKE ?
                            OR admission_no = ? OR (concat(first_name, \" \", last_name) LIKE ? ) ",
            "#{params[:query]}%","#{params[:query]}%","#{params[:query]}%",
            "#{params[:query]}", "#{params[:query]}" ],
          :order => "batch_id asc,first_name asc",:include =>  [{:batch=>:course}]) unless params[:query] == ''
      else
        @archived_students = ArchivedStudent.find(:all,
          :conditions => ["admission_no = ? " , params[:query]],
          :order => "batch_id asc,first_name asc",:include =>  [{:batch=>:course}]) unless params[:query] == ''
      end
      render :partial => "search_ajax"
    end
  end

  def student_annual_overview
    @graph = open_flash_chart_object(770, 350, "/student/graph_for_student_annual_overview?student=#{params[:student]}&year=#{params[:year]}")
  end

  def subject_wise_report
    @student = Student.find(params[:student])
    @subject = Subject.find(params[:subject])
    @examtypes = @subject.examination_types
    @graph = open_flash_chart_object(770, 350, "/student/graph_for_subject_wise_report_for_one_subject?student=#{params[:student]}&subject=#{params[:subject]}")
  end

  def add_guardian
    @parent_info = Guardian.new(params[:parent_detail])
    @countries = Country.all
    if request.post? and @parent_info.save
      flash[:notice] = "#{t('flash5')} #{@parent_info.ward.full_name}"
      redirect_to :controller => "student" , :action => "admission3_1", :id => @parent_info.ward_id
    end
  end

  def list_students_by_course
    @students = Student.find_all_by_batch_id(params[:batch_id], :order => 'first_name ASC')
    render(:update) { |page| page.replace_html 'students', :partial => 'students_by_course' }
  end

  def profile
    @current_user = current_user
    @address = @student.address_line1.to_s + ' ' + @student.address_line2.to_s
    @additional_fields = StudentAdditionalField.all(:conditions=>"status = true")
    @sms_module = Configuration.available_modules
    @sms_setting = SmsSetting.new
    @previous_data = StudentPreviousData.find_by_student_id(@student.id)
    @immediate_contact = Guardian.find(@student.immediate_contact_id) \
      unless @student.immediate_contact_id.nil? or @student.immediate_contact_id == ''
  end
  
  def profile_pdf
    @current_user = current_user
    @student = Student.find(params[:id])
    @address = @student.address_line1.to_s + ' ' + @student.address_line2.to_s
    @additional_fields = StudentAdditionalField.all(:conditions=>"status = true")
    @sms_module = Configuration.available_modules
    @sms_setting = SmsSetting.new
    @previous_data = StudentPreviousData.find_by_student_id(@student.id)
    @immediate_contact = Guardian.find(@student.immediate_contact_id) \
      unless @student.immediate_contact_id.nil? or @student.immediate_contact_id == ''
        
    render :pdf=>'profile_pdf'
  end

  def show_previous_details
    @previous_data = StudentPreviousData.find_by_student_id(@student.id)
    @previous_subjects = StudentPreviousSubjectMark.find_all_by_student_id(@student.id)
  end
  
  def show
    @student = Student.find_by_admission_no(params[:id])
    send_data(@student.photo_data,
      :type => @student.photo_content_type,
      :filename => @student.photo_filename,
      :disposition => 'inline')
  end

  def guardians
    @parents = @student.guardians
  end

  def del_guardian
    @guardian = Guardian.find(params[:id])
    @student = @guardian.ward
    if @guardian.is_immediate_contact?
      if @guardian.destroy
        flash[:notice] = "#{t('flash6')}"
        redirect_to :controller => 'student', :action => 'admission3', :id => @student.id
      end
    else
      if @guardian.destroy
        flash[:notice] = "#{t('flash6')}"
        redirect_to :controller => 'student', :action => 'profile', :id => @student.id
      end
    end
  end

  def academic_pdf
    @course = @student.old_courses.find_by_academic_year_id(params[:year]) if params[:year]
    @course ||= @student.course
    @subjects = Subject.find_all_by_course_id(@course, :conditions => "no_exams = false")
    @examtypes = ExaminationType.find( ( @course.examinations.collect { |x| x.examination_type_id } ).uniq )

    @arr_total_wt = {}
    @arr_score_wt = {}

    @subjects.each do |s|
      @arr_total_wt[s.name] = 0
      @arr_score_wt[s.name] = 0
    end

    @course.examinations.each do |x|
      @arr_total_wt[x.subject.name] += x.weightage
      ex_score = ExaminationResult.find_by_examination_id_and_student_id(x.id, @student.id)
      @arr_score_wt[x.subject.name] += ex_score.marks * x.weightage / x.max_marks unless ex_score.nil?
    end

    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def categories
    @student_categories = StudentCategory.active
    @student_category = StudentCategory.new(params[:student_category])
    if request.post? and @student_category.save
      flash[:notice] = "#{t('flash7')}"
      redirect_to :action => 'categories'
    end
  end

  def category_delete
    if @student_category = StudentCategory.update(params[:id], :is_deleted=>true)
      @student_category.empty_students
    end
    @student_categories = StudentCategory.active
  end

  def category_edit
    @student_category = StudentCategory.find(params[:id])
    
  end

  def category_update
    @student_category = StudentCategory.find(params[:id])
    @student_category.update_attribute(:name, params[:name])
    @student_categories = StudentCategory.active
  end

  def view_all
    @batches = Batch.active
  end

  def advanced_search
    @batches = Batch.all
    @search = Student.search(params[:search])
    if params[:search]
      unless params[:advv_search][:course_id].empty?
        if params[:search][:batch_id_equals].empty?
          batches = Batch.find_all_by_course_id(params[:advv_search][:course_id]).collect{|b|b.id}
        end
      end
      if batches.is_a?(Array)

        @students = []
        batches.each do |b|
          params[:search][:batch_id_equals] = b
          if params[:search][:is_active_equals]=="true"
            @search = Student.search(params[:search])
            @students+=@search.all
          elsif params[:search][:is_active_equals]=="false"
            @search = ArchivedStudent.search(params[:search])
            @students+=@search.all
          else
            @search1 = Student.search(params[:search]).all
            @search2 = ArchivedStudent.search(params[:search]).all
            @students+=@search1+@search2
          end
        end
        params[:search][:batch_id_equals] = nil
      else
        if params[:search][:is_active_equals]=="true"
          @search = Student.search(params[:search])
          @students = @search.all
        elsif params[:search][:is_active_equals]=="false"
          @search = ArchivedStudent.search(params[:search])
          @students = @search.all
        else
          @search1 = Student.search(params[:search]).all
          @search2 = ArchivedStudent.search(params[:search]).all
          @students = @search1+@search2
        end
      end
      @searched_for = ''
      @searched_for += "<span>#{t('name')}: </span>" + params[:search][:first_name_or_middle_name_or_last_name_like].to_s unless params[:search][:first_name_or_middle_name_or_last_name_like].empty?
      @searched_for += " <span>#{t('admission_no')}: </span>" + params[:search][:admission_no_equals].to_s unless params[:search][:admission_no_equals].empty?
      unless params[:advv_search][:course_id].empty?
        course = Course.find(params[:advv_search][:course_id])
        batch = Batch.find(params[:search][:batch_id_equals]) unless (params[:search][:batch_id_equals]).blank?
        @searched_for += "<span>#{t('course_text')}: </span>" + course.full_name
        @searched_for += "<span>#{t('batch')}: </span>" + batch.full_name unless batch.nil?
      end
      @searched_for += "<span>#{t('category')}: </span>" + StudentCategory.find(params[:search][:student_category_id_equals]).name.to_s unless params[:search][:student_category_id_equals].empty?
      unless  params[:search][:gender_equals].empty?
        if  params[:search][:gender_equals] == 'm'
          @searched_for += "<span>#{t('gender')}: </span>#{t('male')}"
        elsif  params[:search][:gender_equals] == 'f'
          @searched_for += " <span>#{t('gender')}: </span>#{t('female')}"
        else
          @searched_for += " <span>#{t('gender')}: </span>#{t('all')}"
        end
      end
      @searched_for += "<span>#{t('blood_group')}: </span>" + params[:search][:blood_group_like].to_s unless params[:search][:blood_group_like].empty?
      @searched_for += "<span>#{t('nationality')}: </span>" + Country.find(params[:search][:nationality_id_equals]).name.to_s unless params[:search][:nationality_id_equals].empty?
      @searched_for += "<span>#{t('year_of_admission')}: </span>" +  params[:advv_search][:doa_option].to_s + ' '+ params[:adv_search][:admission_date_year].to_s unless  params[:advv_search][:doa_option].empty?
      @searched_for += "<span>#{t('year_of_birth')}: </span>" +  params[:advv_search][:dob_option].to_s + ' ' + params[:adv_search][:birth_date_year].to_s unless  params[:advv_search][:dob_option].empty?
      if params[:search][:is_active_equals]=="true"
        @searched_for += "<span>#{t('present_student')}</span>"
      elsif params[:search][:is_active_equals]=="false"
        @searched_for += "<span>#{t('former_student')}</span>"
      else
        @searched_for += "<span>#{t('all_students')}</span>"
      end
    end
  end

   

  #  def adv_search
  #    @batches = []
  #    @search = Student.search(params[:search])
  #    if params[:search]
  #      if params[:search][:is_active_equals]=="true"
  #        @search = Student.search(params[:search])
  #        @students = @search.all
  #      elsif params[:search][:is_active_equals]=="false"
  #        @search = ArchivedStudent.search(params[:search])
  #        @students = @search.all
  #      else
  #        @search = Student.search(params[:search])
  #        @students = @search.all
  #      end
  #    end
  #  end

  def list_doa_year
    doa_option = params[:doa_option]
    if doa_option == "Equal to"
      render :update do |page|
        page.replace_html 'doa_year', :partial=>"equal_to_select"
      end
    elsif doa_option == "Less than"
      render :update do |page|
        page.replace_html 'doa_year', :partial=>"less_than_select"
      end
    else
      render :update do |page|
        page.replace_html 'doa_year', :partial=>"greater_than_select"
      end
    end
  end

  def doa_equal_to_update
    year = params[:year]
    @start_date = "#{year}-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'doa_year_hidden', :partial=>"equal_to_doa_select"
    end
  end

  def doa_less_than_update
    year = params[:year]
    @start_date = "1900-01-01".to_date
    @end_date = "#{year}-01-01".to_date
    render :update do |page|
      page.replace_html 'doa_year_hidden', :partial=>"less_than_doa_select"
    end
  end

  def doa_greater_than_update
    year = params[:year]
    @start_date = "2100-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'doa_year_hidden', :partial=>"greater_than_doa_select"
    end
  end

  def list_dob_year
    dob_option = params[:dob_option]
    if dob_option == "Equal to"
      render :update do |page|
        page.replace_html 'dob_year', :partial=>"equal_to_select_dob"
      end
    elsif dob_option == "Less than"
      render :update do |page|
        page.replace_html 'dob_year', :partial=>"less_than_select_dob"
      end
    else
      render :update do |page|
        page.replace_html 'dob_year', :partial=>"greater_than_select_dob"
      end
    end
  end

  def dob_equal_to_update
    year = params[:year]
    @start_date = "#{year}-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'dob_year_hidden', :partial=>"equal_to_dob_select"
    end
  end

  def dob_less_than_update
    year = params[:year]
    @start_date = "1900-01-01".to_date
    @end_date = "#{year}-01-01".to_date
    render :update do |page|
      page.replace_html 'dob_year_hidden', :partial=>"less_than_dob_select"
    end
  end

  def dob_greater_than_update
    year = params[:year]
    @start_date = "2100-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'dob_year_hidden', :partial=>"greater_than_dob_select"
    end
  end

  def list_batches
    unless params[:course_id] == ''
      @batches = Batch.find(:all, :conditions=>"course_id = #{params[:course_id]}",:order=>"id DESC")
    else
      @batches = []
    end
    render(:update) do |page|
      page.replace_html 'course_batches', :partial=> 'list_batches'
    end
  end

  def advanced_search_pdf
    @searched_for = ''
    @searched_for += "<span>#{t('name')}</span>" + params[:search][:first_name_or_middle_name_or_last_name_like].to_s unless params[:search][:first_name_or_middle_name_or_last_name_like].empty?
    @searched_for += "<span>#{t('admission_no')}</span>" + params[:search][:admission_no_equals].to_s unless params[:search][:admission_no_equals].empty?
    unless params[:advv_search][:course_id].empty?
      course = Course.find(params[:advv_search][:course_id])
      batch = Batch.find(params[:search][:batch_id_equals]) unless (params[:search][:batch_id_equals]).blank?
      @searched_for += "<span>#{t('course_text')}</span>" + course.full_name
      @searched_for += "<span>#{t('batch')}</span>" + batch.full_name unless batch.nil?
    end
    @searched_for += "<span>#{t('category')}</span>" + StudentCategory.find(params[:search][:student_category_id_equals]).name.to_s unless params[:search][:student_category_id_equals].empty?
    unless  params[:search][:gender_equals].empty?
      if  params[:search][:gender_equals] == 'm'
        @searched_for += "<span>#{t('gender')}</span>#{t('male')}"
      elsif  params[:search][:gender_equals] == 'f'
        @searched_for += "<span>#{t('gender')}</span>#{t('female')}"
      else
        @searched_for += "<span>#{t('gender')}</span>#{t('all')}"
      end
    end
    @searched_for += "<span>#{t('blood_group')}</span>" + params[:search][:blood_group_like].to_s unless params[:search][:blood_group_like].empty?
    @searched_for += "<span>#{t('nationality')}</span>" + Country.find(params[:search][:nationality_id_equals]).name.to_s unless params[:search][:nationality_id_equals].empty?
    @searched_for += "<span>#{t('year_of_admission')}:</span>" +  params[:advv_search][:doa_option].to_s + ' '+ params[:adv_search][:admission_date_year].to_s unless  params[:advv_search][:doa_option].empty?
    @searched_for += "<span>#{t('year_of_birth')}:</span>" +  params[:advv_search][:dob_option].to_s + ' ' + params[:adv_search][:birth_date_year].to_s unless  params[:advv_search][:dob_option].empty?
    if params[:search][:is_active_equals]=="true"
      @searched_for += "<span>#{t('present_student')}</span>"
    elsif params[:search][:is_active_equals]=="false"
      @searched_for += "<span>#{t('former_student')}</span>"
    else
      @searched_for += "<span>#{t('all_students')}</span>"
    end

    unless params[:advv_search][:course_id].empty?
      if params[:search][:batch_id_equals].empty?
        batches = Batch.find_all_by_course_id(params[:advv_search][:course_id]).collect{|b|b.id}
      end
    end
    if batches.is_a?(Array)

      @students = []
      batches.each do |b|
        params[:search][:batch_id_equals] = b
        if params[:search][:is_active_equals]=="true"
          @search = Student.search(params[:search])
          @students+=@search.all
        elsif params[:search][:is_active_equals]=="false"
          @search = ArchivedStudent.search(params[:search])
          @students+=@search.all
        else
          @search1 = Student.search(params[:search]).all
          @search2 = ArchivedStudent.search(params[:search]).all
          @students+=@search1+@search2
        end
      end
      params[:search][:batch_id_equals] = nil
    else
      if params[:search][:is_active_equals]=="true"
        @search = Student.search(params[:search])
        @students = @search.all
      elsif params[:search][:is_active_equals]=="false"
        @search = ArchivedStudent.search(params[:search])
        @students = @search.all
      else
        @search1 = Student.search(params[:search]).all
        @search2 = ArchivedStudent.search(params[:search]).all
        @students = @search1+@search2
      end
    end
    render :pdf=>'generate_tc_pdf'
         
  end

  #  def new_adv
  #    if params[:adv][:option] == "present"
  #      @search = Student.search(params[:search])
  #      @students = @search.all
  #    end
  #  end

  def electives
    @batch = Batch.find(params[:id])
    @elective_subject = Subject.find(params[:id2])
    @students = @batch.students
    @elective_group = ElectiveGroup.find(@elective_subject.elective_group_id)
  end

  def assign_students
    @student = Student.find(params[:id])
    StudentsSubject.create(:student_id=>params[:id],:subject_id=>params[:id2],:batch_id=>@student.batch_id)
    @student = Student.find(params[:id])
    @elective_subject = Subject.find(params[:id2])
    render(:update) do |page|
      page.replace_html "stud_#{params[:id]}", :partial=> 'unassign_students'
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg39')}</p>"
    end
  end

  def assign_all_students
    @batch = Batch.find(params[:id])
    @students = @batch.students
    @students.each do |s|
      @assigned = StudentsSubject.find_by_student_id_and_subject_id(s.id,params[:id2])
      StudentsSubject.create(:student_id=>s.id,:subject_id=>params[:id2],:batch_id=>@batch.id) if @assigned.nil?
    end
    @elective_subject = Subject.find(params[:id2])
    render(:update) do |page|
      page.replace_html 'category-list', :partial=>"all_assign"
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg40')}</p>"
    end
  end

  def unassign_students
    StudentsSubject.find_by_student_id_and_subject_id(params[:id],params[:id2]).delete
    @student = Student.find(params[:id])
    @elective_subject = Subject.find(params[:id2])
    render(:update) do |page|
      page.replace_html "stud_#{params[:id]}", :partial=> 'assign_students'
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg41')}</p>"
    end
  end

  def unassign_all_students
    @batch = Batch.find(params[:id])
    @students = @batch.students
    @students.each do |s|
      @assigned = StudentsSubject.find_by_student_id_and_subject_id(s.id,params[:id2])
      @assigned.delete unless @assigned.nil?
    end
    @elective_subject = Subject.find(params[:id2])
    render(:update) do |page|
      page.replace_html 'category-list', :partial=>"all_assign"
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg42')}</p>"
    end
  end

  def fees
    @dates = FinanceFeeCollection.find_all_by_batch_id(@student.batch ,:joins=>'INNER JOIN finance_fees ON finance_fee_collections.id = finance_fees.fee_collection_id',:conditions=>"finance_fees.student_id = #{@student.id} and finance_fee_collections.is_deleted = 0")
    if request.post?
      @student.update_attributes(:has_paid_fees=>params[:fee][:has_paid_fees]) unless params[:fee].nil?
    end
  end

  def fee_details
    @date  = FinanceFeeCollection.find(params[:id2])
    @financefee = @student.finance_fee_by_date @date
    @fee_collection = FinanceFeeCollection.find(params[:id2])
    @due_date = @fee_collection.due_date

    unless @financefee.transaction_id.blank?
      @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")")
    end

    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted = false"])
    @fee_particulars = @fee_collection.fees_particulars(@student)
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
  end


  
  #  # Graphs
  #
  #  def graph_for_previous_years_marks_overview
  #    student = Student.find(params[:student])
  #
  #    x_labels = []
  #    data = []
  #
  #    student.all_courses.each do |c|
  #      x_labels << c.name
  #      data << student.annual_weighted_marks(c.academic_year_id)
  #    end
  #
  #    if params[:graphtype] == 'Line'
  #      line = Line.new
  #    else
  #      line = BarFilled.new
  #    end
  #
  #    line.width = 1; line.colour = '#5E4725'; line.dot_size = 5; line.values = data
  #
  #    x_axis = XAxis.new
  #    x_axis.labels = x_labels
  #
  #    y_axis = YAxis.new
  #    y_axis.set_range(0,100,20)
  #
  #    title = Title.new(student.full_name)
  #
  #    x_legend = XLegend.new("Academic year")
  #    x_legend.set_style('{font-size: 14px; color: #778877}')
  #
  #    y_legend = YLegend.new("Total marks")
  #    y_legend.set_style('{font-size: 14px; color: #770077}')
  #
  #    chart = OpenFlashChart.new
  #    chart.set_title(title)
  #    chart.y_axis = y_axis
  #    chart.x_axis = x_axis
  #
  #    chart.add_element(line)
  #
  #    render :text => chart.to_s
  #  end
  #
  #  def graph_for_student_annual_overview
  #    student = Student.find(params[:student])
  #    course = Course.find_by_academic_year_id(params[:year]) if params[:year]
  #    course ||= student.course
  #    subs = course.subjects
  #    exams = Examination.find_all_by_subject_id(subs, :select => "DISTINCT examination_type_id")
  #    etype_ids = exams.collect { |x| x.examination_type_id }
  #    examtypes = ExaminationType.find(etype_ids)
  #
  #    x_labels = []
  #    data = []
  #
  #    examtypes.each do |et|
  #      x_labels << et.name
  #      data << student.examtype_average_marks(et, course)
  #    end
  #
  #    x_axis = XAxis.new
  #    x_axis.labels = x_labels
  #
  #    line = BarFilled.new
  #
  #    line.width = 1
  #    line.colour = '#5E4725'
  #    line.dot_size = 5
  #    line.values = data
  #
  #    y = YAxis.new
  #    y.set_range(0,100,20)
  #
  #    title = Title.new('Title')
  #
  #    x_legend = XLegend.new("Examination name")
  #    x_legend.set_style('{font-size: 14px; color: #778877}')
  #
  #    y_legend = YLegend.new("Average marks")
  #    y_legend.set_style('{font-size: 14px; color: #770077}')
  #
  #    chart = OpenFlashChart.new
  #    chart.set_title(title)
  #    chart.set_x_legend(x_legend)
  #    chart.set_y_legend(y_legend)
  #    chart.y_axis = y
  #    chart.x_axis = x_axis
  #
  #    chart.add_element(line)
  #
  #    render :text => chart.to_s
  #  end
  #
  #  def graph_for_subject_wise_report_for_one_subject
  #    student = Student.find params[:student]
  #    subject = Subject.find params[:subject]
  #    exams = Examination.find_all_by_subject_id(subject.id, :order => 'date asc')
  #
  #    data = []
  #    x_labels = []
  #
  #    exams.each do |e|
  #      exam_result = ExaminationResult.find_by_examination_id_and_student_id(e, student.id)
  #      unless exam_result.nil?
  #        data << exam_result.percentage_marks
  #        x_labels << XAxisLabel.new(exam_result.examination.examination_type.name, '#000000', 10, 0)
  #      end
  #    end
  #
  #    x_axis = XAxis.new
  #    x_axis.labels = x_labels
  #
  #    line = BarFilled.new
  #
  #    line.width = 1
  #    line.colour = '#5E4725'
  #    line.dot_size = 5
  #    line.values = data
  #
  #    y = YAxis.new
  #    y.set_range(0,100,20)
  #
  #    title = Title.new(subject.name)
  #
  #    x_legend = XLegend.new("Examination name")
  #    x_legend.set_style('{font-size: 14px; color: #778877}')
  #
  #    y_legend = YLegend.new("Marks")
  #    y_legend.set_style('{font-size: 14px; color: #770077}')
  #
  #    chart = OpenFlashChart.new
  #    chart.set_title(title)
  #    chart.set_x_legend(x_legend)
  #    chart.set_y_legend(y_legend)
  #    chart.y_axis = y
  #    chart.x_axis = x_axis
  #
  #    chart.add_element(line)
  #
  #    render :text => chart.to_s
  #  end
  #
  #  def graph_for_exam_report
  #    student = Student.find(params[:student])
  #    examtype = ExaminationType.find(params[:examtype])
  #    course = student.course
  #    subjects = course.subjects_with_exams
  #
  #    x_labels = []
  #    data = []
  #    data2 = []
  #
  #    subjects.each do |s|
  #      exam = Examination.find_by_subject_id_and_examination_type_id(s, examtype)
  #      res = ExaminationResult.find_by_examination_id_and_student_id(exam, student)
  #      unless res.nil?
  #        x_labels << s.name
  #        data << res.percentage_marks
  #        data2 << exam.average_marks * 100 / exam.max_marks
  #      end
  #    end
  #
  #    bargraph = BarFilled.new()
  #    bargraph.width = 1;
  #    bargraph.colour = '#bb0000';
  #    bargraph.dot_size = 5;
  #    bargraph.text = "Student's marks"
  #    bargraph.values = data
  #
  #    bargraph2 = BarFilled.new
  #    bargraph2.width = 1;
  #    bargraph2.colour = '#5E4725';
  #    bargraph2.dot_size = 5;
  #    bargraph2.text = "Class average"
  #    bargraph2.values = data2
  #
  #    x_axis = XAxis.new
  #    x_axis.labels = x_labels
  #
  #    y_axis = YAxis.new
  #    y_axis.set_range(0,100,20)
  #
  #    title = Title.new(student.full_name)
  #
  #    x_legend = XLegend.new("Academic year")
  #    x_legend.set_style('{font-size: 14px; color: #778877}')
  #
  #    y_legend = YLegend.new("Total marks")
  #    y_legend.set_style('{font-size: 14px; color: #770077}')
  #
  #    chart = OpenFlashChart.new
  #    chart.set_title(title)
  #    chart.y_axis = y_axis
  #    chart.x_axis = x_axis
  #    chart.y_legend = y_legend
  #    chart.x_legend = x_legend
  #
  #    chart.add_element(bargraph)
  #    chart.add_element(bargraph2)
  #
  #    render :text => chart.render
  #  end
  #
  #  def graph_for_academic_report
  #    student = Student.find(params[:student])
  #    course = student.course
  #    examtypes = ExaminationType.find( ( course.examinations.collect { |x| x.examination_type_id } ).uniq )
  #    x_labels = []
  #    data = []
  #    data2 = []
  #
  #    examtypes.each do |e_type|
  #      total = 0
  #      max_total = 0
  #      exam = Examination.find_all_by_examination_type_id(e_type.id)
  #      exam.each do |t|
  #        res = ExaminationResult.find_by_examination_id_and_student_id(t.id, student.id)
  #        total += res.marks
  #        max_total += res.maximum_marks
  #      end
  #      class_max =0
  #      class_total = 0
  #      exam.each do |t|
  #        res = ExaminationResult.find_all_by_examination_id(t.id)
  #        res.each do |res|
  #          class_max += res.maximum_marks
  #          class_total += res.marks
  #        end
  #      end
  #      class_avg = (class_total*100/class_max).to_f
  #      percentage = ((total*100)/max_total).to_f
  #      x_labels << e_type.name
  #      data << percentage
  #      data2 << class_avg
  #    end
  #
  #    bargraph = BarFilled.new()
  #    bargraph.width = 1;
  #    bargraph.colour = '#bb0000';
  #    bargraph.dot_size = 5;
  #    bargraph.text = "Student's average"
  #    bargraph.values = data
  #
  #    bargraph2 = BarFilled.new
  #    bargraph2.width = 1;
  #    bargraph2.colour = '#5E4725';
  #    bargraph2.dot_size = 5;
  #    bargraph2.text = "Class average"
  #    bargraph2.values = data2
  #
  #    x_axis = XAxis.new
  #    x_axis.labels = x_labels
  #    y_axis = YAxis.new
  #    y_axis.set_range(0,100,20)
  #
  #    x_legend = XLegend.new("Examinations")
  #    x_legend.set_style('{font-size: 14px; color: #778877}')
  #
  #    y_legend = YLegend.new("Percentage")
  #    y_legend.set_style('{font-size: 14px; color: #770077}')
  #
  #    chart = OpenFlashChart.new
  #
  #    chart.y_axis = y_axis
  #    chart.x_axis = x_axis
  #    chart.y_legend = y_legend
  #    chart.x_legend = x_legend
  #
  #    chart.add_element(bargraph)
  #    chart.add_element(bargraph2)
  #
  #    render :text => chart.render
  #  end
  #
  #  def graph_for_annual_academic_report
  #    student = Student.find(params[:student])
  #    student_all = Student.find_all_by_course_id(params[:course])
  #    total = 0
  #    sum = student_all.size
  #    student_all.each { |s| total += s.annual_weighted_marks(s.course.academic_year_id) }
  #    t = (total/sum).to_f
  #
  #    x_labels = []
  #    data = []
  #    data2 = []
  #
  #    x_labels << "Annual report".to_s
  #    data << student.annual_weighted_marks(student.course.academic_year_id)
  #    data2 << t
  #
  #    bargraph = BarFilled.new()
  #    bargraph.width = 1;
  #    bargraph.colour = '#bb0000';
  #    bargraph.dot_size = 5;
  #    bargraph.text = "Student's average"
  #    bargraph.values = data
  #
  #    bargraph2 = BarFilled.new
  #    bargraph2.width = 1;
  #    bargraph2.colour = '#5E4725';
  #    bargraph2.dot_size = 5;
  #    bargraph2.text = "Class average"
  #    bargraph2.values = data2
  #
  #    x_axis = XAxis.new
  #    x_axis.labels = x_labels
  #
  #    y_axis = YAxis.new
  #    y_axis.set_range(0,100,20)
  #
  #    x_legend = XLegend.new("Examinations")
  #    x_legend.set_style('{font-size: 14px; color: #778877}')
  #
  #    y_legend = YLegend.new("Weightage")
  #    y_legend.set_style('{font-size: 14px; color: #770077}')
  #
  #    chart = OpenFlashChart.new
  #
  #    chart.y_axis = y_axis
  #    chart.x_axis = x_axis
  #    chart.y_legend = y_legend
  #    chart.x_legend = x_legend
  #
  #    chart.add_element(bargraph)
  #    chart.add_element(bargraph2)
  #
  #    render :text => chart.render
  #
  #  end


  private
  def find_student
    @student = Student.find params[:id]
  end
end
