class ExaminationResultController < ApplicationController
#  before_filter :login_required
#  filter_access_to :all
#
#  def add
#    @courses = AcademicYear.this.courses
#    @course1 = @courses[0] unless @courses.nil?
#    @subjects = []
#    @exams = []
#  end
#
#  def add_results
#    @e_id = params[:examination_result][:examination_id]
#    @c_id = Examination.find(@e_id).subject.course
#    @students = Student.find_all_by_course_id(@c_id)
#  end
#
#  def save
#    @exam_id = params[:exam_id]
#    @results = params["examination_result"]
#    @exam = Examination.find(@exam_id)
#    @results.each_pair do |s_id, m|
#      unless ( (r = ExaminationResult.find_by_examination_id_and_student_id(@exam_id, s_id)) == nil )
#        unless m["marks"] == ""
#          marks = m["marks"]
#          percentage = marks.to_i * 100 / @exam.max_marks
#          g_id = Grading.find(:first, :conditions => "min_score <= #{percentage.round}", :order => "min_score desc").id
#        end
#        ExaminationResult.update(r.id, { :marks => marks, :grading_id => g_id, :student_id => s_id, :examination_id => @exam_id } )
#      else
#        r1 = ExaminationResult.new
#        unless m["marks"] == ""
#          r1.marks = m["marks"]
#          percentage = r1.marks.to_i * 100 / @exam.max_marks
#          r1.grading_id = Grading.find(:first, :conditions => "min_score <= #{percentage.round}", :order => "min_score desc").id
#        end
#        r1.student_id = s_id
#        r1.examination_id = @exam_id
#        r1.save
#      end
#    end
#    redirect_to :controller => "examination_result", :action => "add"
#  end
#
#  def update_subjects
#    course = Course.find(params[:course_id]) unless params[:course_id] == ''
#    if course
#      @subjects = Subject.find_all_by_course_id(course.id)
#    else
#      @subjects = []
#    end
#    @exams = []
#    render :update do |page|
#      page.replace_html 'subjects1', :partial => 'subjects', :object => @subjects
#      page.replace_html 'exams1', :partial => 'exams', :object => @exams
#    end
#  end
#
#  def update_one_subject
#    course = Course.find(params[:course_id]) unless params[:course_id] == ''
#    if course
#      @subjects = Subject.find_all_by_course_id(course.id)
#    else
#      @subjects = []
#    end
#    @exams = []
#    render :update do |page|
#      page.replace_html 'subjects1', :partial => 'one_sub', :object => @subjects
#      page.replace_html 'exams1', :partial => 'one_sub_exams', :object => @exams
#    end
#  end
#
#  def update_exams
#    subject = Subject.find(params[:subject_id]) unless params[:subject_id] == ''
#    if subject
#      @exams = subject.examinations
#    else
#      @exams=[]
#    end
#    render :update do |page|
#      page.replace_html 'exams1', :partial => 'exams', :object => @exams
#    end
#  end
#
#  def update_one_sub_exams
#    subject = Subject.find(params[:subject_id]) unless params[:subject_id] == ''
#    if subject
#      @exams = subject.examinations
#    else
#      @exams=[]
#    end
#    render :update do |page|
#      page.replace_html 'exams1', :partial => 'one_sub_exams', :object => @exams
#    end
#  end
#
#  def load_results
#    @exm = Examination.find(params[:examination_id])
#    @students = @exm.subject.course.students.active
#
#    render :update do |page|
#      page.replace_html 'exam_result', :partial => 'exam_result'
#    end
#  end
#
#  def load_one_sub_result
#    @exm = Examination.find(params[:examination_id])
#    @students = @exm.subject.course.students.active
#    render :update do |page|
#      page.replace_html 'exam_result', :partial => 'one_sub_exam_result'
#    end
#  end
#
#  def load_all_sub_result
#    @course   = Course.find(params[:course_id])
#    @examtype = ExaminationType.find(params[:examination_type_id])
#    @subjects = @course.subjects
#    @students = Student.find_all_by_course_id(@course.id,:conditions=>"status = 'Active'")
#    @exams    = Examination.find_all_by_examination_type_id_and_subject_id(@examtype.id, @subjects.collect{|x| x})
#    @res      = ExaminationResult.find_all_by_examination_id(@exams)
#    render :update do |page|
#      page.replace_html 'exam_result', :partial => 'all_sub_exam_result'
#    end
#  end
#
#  def update_examtypes
#    subs = Subject.find_all_by_course_id(params[:course_id])
#    exams = Examination.find_all_by_subject_id(subs, :select => "DISTINCT examination_type_id")
#    etype_ids = exams.collect { |x| x.examination_type_id }
#    @examtypes = ExaminationType.find(etype_ids)
#
#    render :update do |page|
#      page.replace_html "examtypes1", :partial => "examtypes", :object => @examtypes
#    end
#  end
#
#  def view_all_subs
#    @courses = AcademicYear.this.courses
#    @examtypes = []
#
#    if request.post?
#      if params[:examination_result][:examtype_id] == ""
#        flash[:notice] = "Please select an examination type"
#        redirect_to :action => "view_all_subs"
#        return
#      end
#      case params[:commit]
#      when "View"
#        @course   = Course.find(params[:examination_result][:course_id])
#        @examtype = ExaminationType.find(params[:examination_result][:examtype_id])
#        @subjects = @course.subjects
#        @students = Student.find_all_by_course_id(@course.id)
#        @exams    = Examination.find_all_by_examination_type_id(@examtype.id)
#      when "Generate PDF Report"
#        course   = params[:examination_result][:course_id]
#        examtype = params[:examination_result][:examtype_id]
#        subjects = Subject.find_all_by_course_id(course)
#        students = Student.find_all_by_course_id(course, :order => "first_name ASC")
#        exams    = Examination.find_all_by_examination_type_id_and_subject_id(examtype, subjects)
#        res      = ExaminationResult.find_all_by_examination_id(exams)
#
#        _p = PDF::Writer.new
#        _p.text(ExaminationType.find(examtype).name, :font_size => 20, :justification => :center)
#        this_course = Course.find(course)
#        unless this_course.nil?
#          _p.text("Class : " + this_course.grade + " - " + this_course.section, :font_size => 14, :justification => :center)
#        end
#        _p.text(" ", :font_size => 20, :justification => :center)
#        PDF::SimpleTable.new do |t|
#          t.column_order.push("Name")
#          subjects.each {|s| t.column_order.push(s.name)}
#          students.each do |st|
#            x = {"Name"  => st.first_name + " " + st.last_name}
#            subjects.each do |sub|
#              exam = Examination.find_by_subject_id_and_examination_type_id(sub.id, examtype)
#              unless exam.nil?
#                examres = ExaminationResult.find_by_examination_id_and_student_id(exam.id, st.id)
#                x[sub.name] = examres.marks unless examres.nil?
#              end
#            end
#            t.data << x
#          end
#          t.render_on(_p) unless res.nil?
#        end
#        send_data _p.render, :filename => "report.pdf", :type => "application/pdf", :disposition => 'inline'
#      end
#    end
#  end
#
#  def view_one_sub
#    @courses = AcademicYear.this.courses
#    @subjects = []
#    @exams = []
#    if request.post?
#      if params[:examination_result][:exam_id] == ""
#        flash[:notice] = "Please select an examination."
#        redirect_to :action => "view_one_sub"
#        return
#      end
#
#      @exam_id = params[:examination_result][:exam_id]
#      return if @exam_id == ""
#
#      case params[:commit]
#      when "View"
#        @results = ExaminationResult.find_all_by_examination_id(@exam_id)
#        @exam = Examination.find(@exam_id)
#        @selected_course = @exam.subject.course
#        @subjects = @selected_course.subjects
#        @selected_subject = @exam.subject
#        @exams = @selected_subject.examinations
#
#        @sel_course_id = @selected_course.id
#        @sel_subject_id = @selected_subject.id
#        @sel_exam_id = @exam.id
#      when "Generate PDF Report"
#        results = ExaminationResult.find_all_by_examination_id(@exam_id)
#        exam = Examination.find(@exam_id)
#        _p = PDF::Writer.new
#        _p.text(exam.examination_type.name, :font_size => 20, :justification => :center)
#        _p.text(exam.subject.course.grade + " " + exam.subject.course.section, :font_size => 16, :justification => :center)
#        _p.text(" ", :font_size => 20, :justification => :center)
#        PDF::SimpleTable.new do |t|
#          t.column_order.push("Name", "Marks", "Grade")
#          results.each { |r| t.data << {"Name"  => r.student.first_name + " " + r.student.last_name,
#              "Marks" => r.marks, "Grade" => r.grading.name } }
#          t.render_on(_p) unless t.nil?
#        end
#        send_data _p.render, :filename => "hello.pdf", :type => "application/pdf", :disposition => 'inline'
#      end
#    end
#  end
#
#  # pdf-generation
#
#  def one_sub_pdf
#    @institute_name = Configuration.find_by_config_key("SchoolCollegeName")
#    @exm = Examination.find(params[:id])
#    @students = @exm.subject.course.students
#    @i = 0
#    respond_to do |format|
#      format.pdf { render :layout => false }
#    end
#  end
#
#  def all_sub_pdf
#    @course   = Course.find(params[:id])
#    @examtype = ExaminationType.find(params[:id2])
#    @subjects = @course.subjects
#    @students = Student.find_all_by_course_id(@course.id)
#    @exams    = Examination.find_all_by_examination_type_id_and_subject_id(@examtype.id, @subjects.collect{|x| x})
#    @res      = ExaminationResult.find_all_by_examination_id(@exams)
#    @i = 1
#    respond_to do |format|
#      format.pdf { render :layout => false }
#    end
#  end
#
#  def academic_report_course
#    @user = current_user
#    @courses = AcademicYear.this.courses
#  end
#
#  def list_students_by_course
#    @students = Student.find_all_by_course_id(params[:course_id], :conditions=>"status = 'Active'",:order => 'first_name ASC')
#    render(:update) { |page| page.replace_html 'result', :partial => 'students_by_course' }
#  end
#
#  def all_academic_report
#    @student = Student.find(params[:id])
#    course = @student.course
#    @prev_student = @student.previous_student
#    @next_student = @student.next_student
#    @examtypes = ExaminationType.find( ( course.examinations.collect { |x| x.examination_type_id } ).uniq )
#    @graph = open_flash_chart_object(965, 350,
#      "/student/graph_for_academic_report?course=#{course.id}&student=#{@student.id}")
#    @graph2 = open_flash_chart_object(965, 350,
#      "/student/graph_for_annual_academic_report?course=#{course.id}&student=#{@student.id}")
#  end
#
#  def exam_wise_report
#    @courses = AcademicYear.this.courses
#    @examtypes = []
#  end
#
#  def load_examtypes
#    subs = Subject.find_all_by_course_id(params[:course_id])
#    exams = Examination.find_all_by_subject_id(subs, :select => "DISTINCT examination_type_id")
#    etype_ids = exams.collect { |x| x.examination_type_id }
#    @examtypes = ExaminationType.find(etype_ids)
#
#    render :update do |page|
#      page.replace_html "examtypes1", :partial => "load_examtypes", :object => @examtypes
#    end
#  end
#
#  def load_course_all_student
#    @examtype = ExaminationType.find(params[:examination_type_id])
#    @course = Course.find(params[:course_id])
#    @students = Student.find_all_by_course_id(params[:course_id], :conditions=>"status = 'Active'",:order => 'first_name ASC')
#    render(:update) { |page| page.replace_html 'student', :partial => 'load_course_student' }
#  end
#
#  def exam_report
#    @user = current_user
#    @examtype = ExaminationType.find(params[:exam])
#    @course = Course.find(params[:course])
#    @student = Student.find(params[:student]) if params[:student]
#    @student ||= @course.students.first
#    @prev_student = @student.previous_student
#    @next_student = @student.next_student
#    @subjects = @course.subjects_with_exams
#    @results = {}
#    @subjects.each do |s|
#      exam = Examination.find_by_subject_id_and_examination_type_id(s, @examtype)
#      res = ExaminationResult.find_by_examination_id_and_student_id(exam, @student)
#      @results[s.id.to_s] = { 'subject' => s, 'result' => res } unless res.nil?
#    end
#    @graph = open_flash_chart_object(770, 350,
#      "/student/graph_for_exam_report?course=#{@course.id}&examtype=#{@examtype.id}&student=#{@student.id}")
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
end