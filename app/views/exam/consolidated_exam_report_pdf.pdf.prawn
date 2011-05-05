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
pdf.move_down(100)
pdf.text @exam_group.batch.name+"-"+@exam_group.name , :size => 18 ,:at=>[0,620]
pdf.fill_color "736F6E"
pdf.text "Consolidated Report",:size => 9,:at=>[0,610]
pdf.fill_color "000000"
pdf.move_down(20)
data = Array.new(){Array.new()}
table_heading = Array.new()
table_heading.push "Name"

@exam_group.exams.each do |exam|
  table_heading.push exam.subject.code
end
unless @exam_group.exam_type == 'Grades'
  table_heading.push "Total"
  table_heading.push "Maximum Marks"
  table_heading.push "Percentage"
end

widths = {0=>100}
exams_count = @exam_group.exams.count
exams_count.times do |col_no|
  widths[col_no+1] = 300/exams_count
end
unless @exam_group.exam_type == 'Grades'
  widths[exams_count+1]=50
  widths[exams_count+2]=50
  widths[exams_count+3]=50
end


@exam_group.batch.students.each do |student|
  student_marks = Array.new()
  total_marks = 0
  total_max_marks = 0
  student_marks.push student.full_name.upcase
  @exam_group.exams.each do |exam|
    exam_score = ExamScore.find_by_student_id_and_exam_id(student,exam)
    unless exam_score.nil?
      unless @exam_group.exam_type == 'Grades'
        mark = exam_score.marks || "-"
        total_marks += exam_score.marks || 0
        total_max_marks += exam.maximum_marks
        if @exam_group.exam_type == 'MarksAndGrades'
             mark = "#{exam_score.marks || "-"}(#{exam_score.grading_level || "-"})"
        end
      else
        mark=exam_score.grading_level || "-"
      end
    else
      mark = "-"
    end
    student_marks.push mark
  end
  unless @exam_group.exam_type == 'Grades'
    student_marks.push total_marks
    student_marks.push total_max_marks
    unless total_max_marks==0
      percentage = (total_marks/total_max_marks.to_f)*100
      student_marks.push "%.2f" %percentage
    else
      student_marks.push  "-"
    end
  end
  data.push student_marks
  
end
pdf.bounding_box([20,580], :width => 500,:height=>550) do
pdf.table data, :width => 500,:headers => table_heading,
:header_color => "eeeeee",
:border_color => "000000",
:position => :center,
:font_size => 9,
:column_widths => widths,
:row_colors => ["FFFFFF","DDDDDD"]
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