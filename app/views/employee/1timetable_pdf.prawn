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
pdf.text @employee.full_name, :size => 18 ,:align => :center

data = Array.new(){Array.new()}
@weekday.each_with_index do |week,i|
  timetable_row = []
  timetable_row << week[0,3].upcase
  unless @weekday_timetable[i.to_s].nil?
    @weekday_timetable[i.to_s].each do |tte|
      timetable_entry = []
      timetable_entry <<(tte.class_timing.start_time.strftime("%I:%M %p")+" to "+tte.class_timing.end_time.strftime("%I:%M %p")) unless tte.class_timing.start_time.nil?
      timetable_entry<< tte.subject.batch.course.full_name
      timetable_entry << (tte.subject.elective_group.nil? ? tte.subject.code : (tte.subject.elective_group.subjects.select { |subs| @employee_subjects_ids.include?(subs.id.to_s)  }).first.code)
timetable_row << timetable_entry.join("\n")
    end
    data << timetable_row
  end
end

pdf.table data, :width => 550,
  :border_color => "000000",
  :header_color => "eeeeee",
  :header_text_color  => "97080e",
  :position => :left,
  :row_colors => ["FFFFFF","DDDDDD"],
  :align =>  :center,
  :column_widths => {0=>50},
  :font_size => 9

