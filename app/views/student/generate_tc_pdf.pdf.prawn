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
pdf.text "Transfer Certificate" , :size => 12 ,:align=>:center

pdf.move_down(20)
data=Array.new(){Array.new()}

data = [["Name", @student.full_name],
["Admission no.", @student.admission_no],
["Date of admission", @student.admission_date.strftime("%d %B %Y")],
["DOB", @student.date_of_birth.strftime("%d %B %Y")],
["Last attended course", @student.batch.full_name],
["Blood group", @student.blood_group],
["Gender", @student.gender_as_text],
["Nationality", @student.nationality.name],
["Language", @student.language]]
            
if @father
                data.push ['Father', @father.full_name]
elsif @mother
                data.push ['Mother', @mother.full_name]
else
    unless @immediate_contact.nil?
                data.push [@immediate_contact.relation, @immediate_contact.full_name ]
   end
end
unless @student.student_category.nil?
                data.push ["Category", @student.student_category.name]
end

data.push  ["Religion", @student.religion],
        ["Address", @student.address_line1],
        ["", @student.address_line2],
        ["City", @student.city],
        ["State", @student.state],
        ["Country", @student.country.name],
        ["Reason for leaving", @student.status_description]




pdf.table data, :width => 500,
                :border_color => "000000",
                :header_color => "c3d9ff",
                :header_text_color  => "97080e",
                :position => :center,
                :row_colors => ["FFFFFF","DDDDDD"],
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