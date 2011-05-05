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
pdf.text "Time Table", :size => 18 ,:align => :center
pdf.text @batch.full_name, :size => 18 ,:align => :center
data = Array.new(){Array.new()}
timings= Array.new()
timings.push "Day"
@class_timing.each do |class_time|
   timings.push class_time.name
 end

@day.each do |d|
timetable_row = Array.new()
timetable_row.push @weekday[d.weekday.to_i][0,3].upcase
@class_timing.each do |pt1|
tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id(d.id, pt1.id, @batch.id)
unless tte.nil?
    period = tte.subject.nil?? " ":tte.subject.code
     if Configuration.available_modules.include?('HR')
           teacher = "\n("+tte.employee.employee_number+")"    unless tte.employee.nil?
           timetable_row.push period+teacher.to_s
            else
            timetable_row.push period
     end
else
    timetable_row.push " "
end
end
data.push timetable_row
end
pdf.table data, :width => 500,
                :headers => timings,
                :border_color => "000000",
                :header_color => "eeeeee",
                :header_text_color  => "97080e",
                :position => :center,
                :row_colors => ["FFFFFF","DDDDDD"],
                :align =>  :center,
                :font_size => 9