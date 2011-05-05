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
pdf.move_down(125)

subject_no = @subjects.size+1
exam_no = @exam_groups.size+1
@gr = 0
data = Array.new(subject_no+1){Array.new(exam_no+1)}
@max_total = 0
@marks_total = 0
subject_no.times do |i|
@g = 0
    exam_no.times do |j|
        @exam = Exam.find_by_subject_id_and_exam_group_id(@subjects[i-1].id,@exam_groups[j-1].id)
        exam_score = ArchivedExamScore.find_by_student_id(@student.id, :conditions=>{:exam_id=>@exam.id})unless @exam.nil?
            data[0][0] = 'Subject'
            data[0][j] = @exam_groups[j-1].name
unless exam_score.nil?
                if @exam_groups[j-1].exam_type == "MarksAndGrades"
                    data[i][j] = "#{exam_score.marks} |#{@exam.maximum_marks}  #{exam_score.grading_level.name}"
                elsif @exam_groups[j-1].exam_type == "Marks"
                    data[i][j] = "#{exam_score.marks} |#{@exam.maximum_marks}" unless @exam.nil?
                else
                    data[i][j] = exam_score.grading_level.name
                    @g = 1
                    @gr = 1
                end
                    data[0][exam_no] = 'Total'
                    unless @g == 1
                    total_score = ArchivedExamScore.new()
                        data[i][exam_no] = total_score.grouped_exam_subject_total(@subjects[i-1],@student,@type)
                        
                    else
                        data[i][exam_no] =''
                    end
if i == 1
                    if @exam_groups[j-1].exam_type == "MarksAndGrades"
                        data[subject_no][j] = @exam_groups[j-1].archived_total_marks(@student)[0]
                        if j < exam_no-1
                            @marks_total = @marks_total + @exam_groups[j-1].archived_total_marks(@student)[0]
                            @max_total = @max_total + @exam_groups[j-1].archived_total_marks(@student)[1]
                        end
                    elsif @exam_groups[j-1].exam_type == "Marks"
                        data[subject_no][j] = @exam_groups[j-1].archived_total_marks(@student)[0]
                        if j < exam_no-1
                            @marks_total = @marks_total + @exam_groups[j-1].archived_total_marks(@student)[0]
                            @max_total = @max_total + @exam_groups[j-1].archived_total_marks(@student)[1]
                        end
                    else
                        data[subject_no][j] = ''
                    end
end
                    
    end
                    data[i][0]= @subjects[i-1].name
                    
                    data[subject_no][0] = 'Total'
end
                    

end
pdf.table data, :width => 500,
                                    :border_color => "000000",
                                    :position => :center,
                                    :row_colors => ["FFFFFF","DDDDDD"],
                                    :align => { 0 => :left, 1 => :center, 2 => :center, 3 =>:center}

pdf.move_down(30)
if @gr == 0
aggregate = @marks_total*100/@max_total.to_f unless @max_total == 0


pdf.text @student.full_name, :size => 18 ,:at=>[10,620]
pdf.text "Examination results" ,:size => 7,:at=>[10,610]
pdf.text "Total marks: #{@marks_total} , Aggregate: " + "%.2f" %aggregate + "%",  :at=>[350,620]
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
