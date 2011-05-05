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
pdf.text @employee.full_name ,:align=>:left,:size=>14
pdf.text @employee.employee_number ,:align=>:left,:size=>14
@leave_types.each do |lt|
 leave_count = EmployeeLeave.find_by_employee_leave_type_id_and_employee_id(lt.id, @employee.id)
unless leave_count.reset_date.nil?
@report = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id, lt.id, :conditions=> ["attendance_date >= '#{leave_count.reset_date}'"])
else
 @report = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id, lt.id)
end
    if @report == []
        data.push [lt.name ,"No dates"]
    else
        @report.each do |r|
           data.push [lt.name,r.attendance_date.strftime("%B %d, %Y")]
        end
    end
end

pdf.move_down(30)

total_leave = 0
@leave_count.each do |e|
leave_type = EmployeeLeaveType.find_by_id(e.employee_leave_type_id)
data.push  ["Total #{leave_type.name}","#{e.leave_taken}/#{e.leave_count}"]
total_leave+= e.leave_taken
end
pdf.move_down(10)

data.push ["Net total leaves","#{total_leave}"]


pdf.move_down(20)

pdf.table data, :width => 450,
                :column_widths => {0=>300,1=>150},
                :border_color => "000000",
                :position => :center,
                :headers => ['Leave Types','Dates'],
                :header_color => "EEEEEE",
                :header_text_color => "97080e",
                :row_colors => ["FFFFFF","DDDDDD"],
                :align => { 0 => :left, 1 => :right}




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