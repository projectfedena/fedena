pdf.header pdf.margin_box.top_left do
  if FileTest.exists?("#{RAILS_ROOT}/public/uploads/image/institute_logo.jpg")
    logo = "#{RAILS_ROOT}/public/uploads/image/institute_logo.jpg"
  else
    logo = "#{RAILS_ROOT}/public/images/application/app_fedena_logo.jpg"
  end
  @institute_name=Configuration.get_config_value('InstitutionName');
  @institute_address=Configuration.get_config_value('InstitutionAddress');
  pdf.image logo, :position=>:left, :height=>50, :width=>50
  pdf.font "Helvetica" do
    info = [[@institute_name],
      [@institute_address]]
    pdf.move_up(50)
    pdf.fill_color "97080e"
    pdf.table info, :width => 400,
      :align => {0 => :center},
      :position => :center,
      :border_color => "FFFFFF"
    pdf.move_down(20)
    pdf.stroke_horizontal_rule
  end
end




@all_batches.each do |b|
  @type = params[:type]
  if @type == 'grouped'
		@grouped_exams = GroupedExam.find_all_by_batch_id(b.id)
		@exam_groups = []
		@grouped_exams.each do |x|
		  @exam_groups.push ExamGroup.find(x.exam_group_id)
		end
	  else
		@exam_groups = ExamGroup.find_all_by_batch_id(b.id)
  end
  general_subjects = Subject.find_all_by_batch_id(b.id, :conditions=>"elective_group_id IS NULL AND is_deleted=false")
  student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{b.id}")
  elective_subjects = []
  student_electives.each do |elect|
    elective_subjects.push Subject.find(elect.subject_id)
  end
  @subjects = general_subjects + elective_subjects

  exam = ExamScore.new()
  @aggr =  exam.batch_wise_aggregate(@student,b)
    data =Array.new(){Array.new()}
  table_header = Array.new()
  table_header<<"Subject"
  @exam_groups.each do |exam_group|
    table_header<<exam_group.name
  end
  table_header<<"Total"

col_widths = Hash.new()
col_widths[0]=200

  @subjects.each do |subject|
    table_row=Array.new()
	table_row<<subject.name
           sub_total="-"
    @mmg = 1;@g = 1

    @exam_groups.each_with_index do |exam_group,i|
       col_widths[i+1]=(250/@exam_groups.size)
    @exam = Exam.find_by_subject_id_and_exam_group_id(subject.id,exam_group.id)
    exam_score = ExamScore.find_by_student_id(@student.id, :conditions=>{:exam_id=>@exam.id})unless @exam.nil?
	unless exam_score.nil?
		if exam_group.exam_type == "MarksAndGrades"
			unless @exam.nil?
				table_row<<"#{exam_score.marks || "-"}|#{@exam.maximum_marks}|#{exam_score.grading_level || "-"}"
                         else
                         table_row<<"-"
			end
		elsif exam_group.exam_type == "Marks"
                unless @exam.nil?
			  table_row<<"#{(exam_score.marks)} | #{(@exam.maximum_marks)}"
                 else
                  table_row<<"-"
                 end
		else
			  table_row<<exam_score.grading_level.name unless exam_score.nil?
			  @g = 0
		end
                else
                table_row<<"- "
	end
	total_score = ExamScore.new()
	if @mmg == @g
                sub_total=total_score.grouped_exam_subject_total(subject,@student,@type,b)
         end

  end
table_row<<sub_total
    data<<table_row


end
  totals_row = Array.new()
  totals_row<<"Total"
  @max_total = 0
  @marks_total = 0
  @exam_groups.each do |exam_group|
		if exam_group.exam_type == "MarksAndGrades"
		  totals_row<<exam_group.total_marks(@student)[0]
		elsif exam_group.exam_type == "Marks"
		  totals_row<<exam_group.total_marks(@student)[0]
		else
		  totals_row<<"-"
		end
		unless exam_group.exam_type == "Grades"
		  @max_total = @max_total + exam_group.total_marks(@student)[1]
		  @marks_total = @marks_total + exam_group.total_marks(@student)[0]
		end
    end
totals_row<<"-"
data<<totals_row


col_widths[@exam_groups.size+1]=50
        pdf.move_down(100)
  pdf.text "Marklist for #{@student.full_name}  in  #{b.full_name}   "
    pdf.move_down(10)
      pdf.table data,
          :width=>500,
        :headers => table_header,
      :header_color => "eeeeee",
      :border_color => "000000",
      :position => :center,
      :font_size =>11,
      :row_colors => ["FFFFFF","DDDDDD"]

 
   
     @additional_exam_groups = AdditionalExamGroup.find_all_by_batch_id(b)
          @additional_exam_groups.each do |additional_exam_group|
              if additional_exam_group.students.include?(@student)
               data = Array.new(){Array.new()}
              @additional_exams = AdditionalExam.find_all_by_additional_exam_group_id(additional_exam_group)
              table_header = Array.new()
              table_header<<"Subject"
              table_header<<"Marks" unless additional_exam_group.exam_type == "Grades"
              table_header<<"Grades" unless additional_exam_group.exam_type == "Marks"
              @additional_exams.each do |exam|
                    unless (exam.score_for(@student).marks.nil? &&  exam.score_for(@student).grading_level_id.nil?)
                            table_row=Array.new()
                            table_row<<exam.subject.name
                            table_row<<exam.score_for(@student).marks || "-"      unless additional_exam_group.exam_type == "Grades"
                            table_row<< exam.score_for(@student).grading_level || "-"       unless additional_exam_group.exam_type == "Marks"
                            data<<table_row
                    end
             end
             unless data.empty?
                    pdf.move_down(100)
                    pdf.text "Marklist for #{@student.full_name}  in #{additional_exam_group.name} , #{b.full_name}   "
                    pdf.move_down(10)
                    pdf.table data,
                                    :width=>500,
                                     :headers => table_header,
                                      :column_widths =>{ 0 => 200},
                                     :header_color => "eeeeee",
                                     :border_color => "000000",
                                     :position => :center,
                                     :font_size =>11,
                                     :row_colors => ["FFFFFF","DDDDDD"]
                end
          end
      end




pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
     pdf.font "Helvetica" do
        signature = [[""]]
        pdf.table signature, :width => 500,
                :align => {0 => :right,1 => :right},
                :headers => ["Signature"],
                :header_text_color  => "DDDDDD",
                :border_color => "FFFFFF",
                :position => :center
        pdf.move_down(20)
        pdf.stroke_horizontal_rule
    end
end
pdf.start_new_page unless b == @all_batches.last
end