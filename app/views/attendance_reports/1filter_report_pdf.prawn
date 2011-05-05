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

unless @report.empty?
  working_days = @report.size


  pdf.move_down(80)
    if @config.config_value == 'Daily'
   pdf.text  "Total no. of working days = " + working_days.to_s
     else
   pdf.text  "Total no. of working hours = " + working_days.to_s
    end
pdf.move_down(10)
pdf.text "Filtered: "+ @range.to_s + " " + @value.to_s
  pdf.move_down(10)
  pdf.stroke_horizontal_rule
  pdf.move_down(20)
  data = Array.new(){Array.new()}
  data.push ["Name","Total","Percentage"]

@students.each do |student|
         leaves =0
      @report.each do |report|
      @attendance = Attendance.find_by_student_id_and_period_table_entry_id(student.id, report.id)
        unless @attendance.nil?
         if @config.config_value == 'Daily'
           leaves += 0.5 if @attendance.forenoon
           leaves += 0.5 if @attendance.afternoon
          else
           leaves += 1
          end
        end
      end
   total = (working_days - leaves).to_f
   percentage =  (total/working_days)*100 unless working_days == 0


   data.push [student.full_name,total,percentage.round(2)] if percentage.round(2) < @value.to_f and @range == 'Below'
   data.push [student.full_name,total,percentage.round(2)] if percentage.round(2) > @value.to_f and @range == 'Above'
   data.push [student.full_name,total,percentage.round(2)] if percentage.round(2) == @value.to_f and @range == 'Equals'
end
        
    pdf.table data, :width => 500,
      :border_color => "000000",
      :header_color => "eeeeee",
      :position => :center,
      :font_size => 8,
      :column_widths => {0=>300,1=>100,2=>100},
      :align => {0=>:left,1=>:center,2=>:center},
      :row_colors => ["FFFFFF","DDDDDD"]

else

pdf.text "No reports for the given period"


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
