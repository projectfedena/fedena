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


@exam_groups.each do |exam_group|
pdf.move_down(120)
data = Array.new(){Array.new()}
pdf.text exam_group.name+"-"+@subject.name , :size => 18 ,:at=>[10,620]
pdf.text exam_group.batch.name,:size => 12,:at=>[10,610]
  if exam_group.exam_type == 'Marks'
    data.push [ 'Student', 'Marks', 'Max Marks'  ]
  elsif exam_group.exam_type == 'Grades'
    data.push [ 'Student', 'Grades']
  else
    data.push [ 'Student', 'Marks', 'Max marks', 'Grades']
  end
  exam = Exam.find_by_exam_group_id_and_subject_id(exam_group.id,@subject.id)
  @students.each do |student|
    exam_score = ExamScore.find_by_student_id(student.id,:conditions=>{:exam_id=>exam.id}) unless exam.nil?
    unless exam_score.nil?
      if exam_group.exam_type == 'Marks'
        data.push [ student.full_name, exam_score.marks || "-", exam.maximum_marks  ]
      elsif exam_group.exam_type == 'Grades'
        data.push [ student.full_name, exam_score.grading_level || "-"]
      else
        data.push [ student.full_name,exam_score.marks || "-", exam.maximum_marks, (exam_score.grading_level || '-')]
      end
    else
      if exam_group.exam_type == 'Marks'
        data.push [ student.full_name, '-', '-'  ]


      elsif exam_group.exam_type == 'Grades'
        data.push [ student.full_name, '-']


      else
        data.push [ student.full_name,'-', '-', '-']


      end
    end
  end
  unless exam.nil?
    if exam_group.exam_type == 'Marks'
      data.push [ 'Average', exam_group.subject_wise_batch_average_marks(@subject.id),'-']
    elsif exam_group.exam_type == 'MarksAndGrades'

      data.push [ "Average",exam_group.subject_wise_batch_average_marks(@subject.id),  '-','-']

    else
      data.push [ "Average","-"]
    end
  end
  pdf.table data, :width => 500,
    :border_color => "000000",
    :position => :center,
    :font_size => 8,
    :column_widths => {0=>200,1=>100,2=>100,3=>100},
    :row_colors => ["FFFFFF","DDDDDD"]

  pdf.start_new_page unless exam_group == @exam_groups.last
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