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
data = Array.new(){Array.new()}

i = 530
@subjects = @subjects.map do |s|
pdf.move_down(30)
pdf.text s.name, :at => [0,i],:style => :bold
    pdf.move_down(10)
     heading = [["Examination Name","Marks Obtained","Max Marks","Grade","(IN %)"]]
        pdf.table heading,          :border_color => "000000",
                                     
                                     :row_colors => ["DDDDDD"],
                                     :position => :center,
                                     
                                     :column_widths => { 0 => 120, 1 => 100,2 => 100,3 => 100,4 => 100 },
                                     :align => { 0 => :left, 1 => :left, 2 => :left, 3 => :left,4 => :left}
    
    
    @examtypes.map do |e|
        exam = Examination.find_by_examination_type_id_and_subject_id(e.id, s.id)
        examres = ExaminationResult.find_by_student_id_and_examination_id(@student.id,exam.id)unless exam.nil?

       


        unless examres.nil?
            if examres.grading.nil?
               grade = "NA"
            else
               grade = examres.grading.name
            end

            student_marks = [[examres.name,examres.marks,examres.examination.max_marks,grade,examres.percentage_marks]]
            pdf.table student_marks, :border_color => "000000",
                                     :position => :center,
                                     :column_widths => { 0 => 120, 1 => 100,2 => 100,3 => 100,4 => 100 },
                                     :align => { 0 => :left, 1 => :left, 2 => :left, 3 => :left,4 => :left}
        end
        
    end
    sub_percent_total = @arr_score_wt[s.name] * 100.0 / @arr_total_wt[s.name] unless @arr_total_wt[s.name]
    grade_weighted_scores = Grading.find_from_percentage(sub_percent_total) if sub_percent_total
    weighted_marks = [["Weighted scores",@arr_score_wt[s.name],@arr_total_wt[s.name],grade_weighted_scores,sub_percent_total]]
    pdf.table weighted_marks,  :border_color => "000000",
                               :position => :center,
                               :column_widths => { 0 => 120, 1 => 100,2 => 100,3 => 100,4 => 100 },
                               :align => { 0 => :left, 1 => :left, 2 => :left, 3 => :left,4 => :left}
  
    i = i - 120
end
    pdf.text "TOTAL (overall)", :at => [0,i],:style => :bold
    pdf.move_down(80)
    overall = [["Grade","(IN%)"]]
    
    pdf.table overall,:border_color => "000000",
                      :row_colors => ["DDDDDD"],
                      :position => :center,
                      :column_widths => { 0 => 120, 1 => 100},
                      :align => { 0 => :left, 1 => :left,}
    percentage_total = @student.annual_average_marks_for_a_course(@course)
    overall_marks = [[Grading.find_from_percentage(percentage_total).name,percentage_total]]
    pdf.table overall_marks,:border_color => "000000",
                      :position => :center,
                      :column_widths => { 0 => 120, 1 => 100},
                      :align => { 0 => :left, 1 => :left,}


     pdf.font "Helvetica" do
        signature = [["Signature"]]
        pdf.table signature, :width => 500,
                :align => {0 => :right},
                :border_color => "FFFFFF",
                :position => :center
        pdf.move_down(20)
        pdf.stroke_horizontal_rule
    end

