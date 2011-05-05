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
student = @students

  pdf.move_down(80)
  pdf.text "Student wise report for "+@exam_group.name+", Batch:"+@batch.name
  pdf.move_down(10)
  pdf.stroke_horizontal_rule
  pdf.move_down(20)
  pdf.text student.full_name , :size => 18
  pdf.text "Exam :"+@exam_group.name,:size => 7
  data = Array.new(){Array.new()}
  pdf.move_down(20)
  if @exam_group.exam_type == 'Marks'
    data.push ["Subject","Marks","Maximum marks","Percentage"]
    total_marks = 0
    total_max_marks = 0
    @exam_group.exams.each do |exam|
      exam_score = ArchivedExamScore.find_by_student_id_and_exam_id(student,exam)
      unless exam_score.nil?
        mark = exam_score.marks
        total_marks += mark
        total_max_marks += exam.maximum_marks
      else
        mark = "-"
      end
      data.push [exam.subject.name,mark,exam.maximum_marks,(exam_score.calculate_percentage unless exam_score.nil?)]
    end
    pdf.table data, :width => 500,
      :border_color => "000000",
      :position => :center,
      :font_size => 8,
      :column_widths => {0=>200,1=>100,2=>100,3=>100},
      :align => {0=>:left,1=>:center,2=>:center,3=>:center},
      :row_colors => ["FFFFFF","DDDDDD"]


  elsif @exam_group.exam_type == 'Grades'
    data.push ["Subject","Grade"]
    @exam_group.exams.each do |exam|
      exam_score = ArchivedExamScore.find_by_student_id_and_exam_id(student,exam)
      unless exam_score.nil?
      data.push [exam.subject.name,exam_score.grading_level.name]
      else
      data.push [exam.subject.name,"-"]
      end
    end
    pdf.table data, :width => 500,
      :border_color => "000000",
      :position => :center,
      :font_size => 8,
      :column_widths => {0=>200,1=>100,2=>100,3=>100},
      :align => {0=>:left,1=>:center,2=>:center,3=>:center},
      :row_colors => ["FFFFFF","DDDDDD"]

  else
    data.push ["Subject","Marks","Grade","Maximum marks","Percentage"]
    total_marks = 0
    total_max_marks = 0
    @exam_group.exams.each do |exam|
      exam_score = ArchivedExamScore.find_by_student_id_and_exam_id(student,exam)
      unless exam_score.nil?
        mark = exam_score.marks
        grade = exam_score.grading_level.name
        total_marks += mark
        total_max_marks += exam.maximum_marks
      else
        mark = "-"
        grade = "-"
      end
      data.push [exam.subject.name,mark,grade,exam.maximum_marks,(exam_score.calculate_percentage unless exam_score.nil?)]
    end
    pdf.table data, :width => 500,
      :border_color => "000000",
      :header_color => "eeeeee",
      :position => :center,
      :font_size => 8,
      :column_widths => {0=>200,1=>75,2=>75,3=>75,4=>100},
      :align => {0=>:left,1=>:center,2=>:center,3=>:center,4=>:center},
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
