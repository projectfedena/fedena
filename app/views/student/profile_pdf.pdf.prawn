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
      info = [[{:text=>@institute_name, :font_style=>:bold}],
        [{:text=>@institute_address, :font_style=>:bold}]]
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
 #foto = url_for(:controller=>"student", :action => "show", :id => @student.admission_no)
pdf.move_down(100)
pdf.image StringIO.new(@student.photo_data), :height=>50, :width=>50,:at=>[0,640]
pdf.text "Student Profile" ,:size => 12, :at=>[60,620]
pdf.fill_color "736F6E"
pdf.text @student.full_name , :size => 9 ,:at=>[60,610]
pdf.fill_color "000000"
pdf.move_down(20)



unless @student.student_category.nil?
    cat=@student.student_category.name
else
    cat = " "
end
unless @student.batch.employee_id.nil?
  @assigned_employees = Employee.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@student.batch.employee_id}\")")
  group_tutor = @assigned_employees.map{|e| e.full_name}
else
  group_tutor = " "
end
    pdf.move_down(20)
     data = [["Admission Number" , @student.admission_no],
                ["Admission Date" , @student.admission_date.strftime("%d %b, %Y")],
                 ["Batch" , @student.batch.full_name ],
                 ["Course",(@student.batch.course).course_name],
                ["Date of Birth",@student.date_of_birth.strftime("%d %b, %Y")],
                ["Blood group", @student.blood_group],
                ["Gender",@student.gender_as_text],
                ["Nationality", @student.nationality.name],
                ["Language",@student.language],
                ["Category",cat],
                ["Religion", @student.religion],
                ["Address",@address],
                ["City", @student.city],
                ["State",@student.state],
                ["Country",@student.country.name],
                ["Phone",@student.phone1],
                ["Mobile",@student.phone2],
                ["Email",@student.email],
                ["Group Tutor",group_tutor]]
unless @immediate_contact.nil?
    unless @immediate_contact.mobile_phone.empty?
      data.push ["Immediate contact", @immediate_contact.full_name + "(" + @immediate_contact.mobile_phone + ")"]
    else
      data.push ["Immediate contact", @immediate_contact.full_name ]
    end
end

unless @additional_fields.nil?
@additional_fields.each do |field|
    detail = StudentAdditionalDetails.find_by_additional_field_id_and_student_id(field.id,@student.id)
   unless detail.nil?
     data.push [field.name,detail.additional_info]
   else
         data.push [field.name," "]
   end
end
pdf.table data, :width => 540,
                :border_color => "736F6E",
                :font_size =>9,
                :position => :center,
                :row_colors => ["FFFFFF","DDDDDD"],
                :column_widths =>{ 0 => 270, 1 => 270},
                :horizontal_padding => 20,
                :vertical_padding => 5,
                :align => { 0 => :left, 1 => :left}
end




unless @previous_data.blank?
  pdf.start_new_page
pdf.move_down(80)

data = Array.new{Array.new()}

@previous_data.each do |p|

data = [["Institution Name" , p.institution.to_s],
                ["Course" , p.course],
                ["Year" , p.year.to_s ],
                ["Total Marks" , p.total_mark.to_s ]]

end
pdf.table data, :border_color => "000000",
                :position => :center,
                :row_colors => ["FFFFFF","DDDDDD"],
                :column_widths =>{ 0 => 200, 1 => 200},
                :align => { 0 => :left, 1 => :left}

end
data = Array.new{Array.new()}

@previous_subjects_marks.each do |s|

data<<[ s.subject, s.mark]



end
pdf.table data, :border_color => "000000",
                :position => :center,
                :row_colors => ["FFFFFF","DDDDDD"],
                :headers => [{:text=>"Subjects : ",:font_style=>:bold},{:text=>""}],
                :column_widths =>{ 0 => 200, 1 => 200},
               :align => { 0 => :left, 1 => :left}







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