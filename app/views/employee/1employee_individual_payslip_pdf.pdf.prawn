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

pdf.move_down(90)
pdf.text "Employee Payslip" ,:align=>:center,:size=>14
pdf.move_down(20)
info = Array.new(){Array.new()}
info.push ["Name ", @employee.full_name]
info.push ["Id  ",@employee.employee_number]
info.push ["Grade ",  EmployeeGrade.find(@employee.employee_grade_id).name]
info.push ["Category ", EmployeeCategory.find(@employee.employee_category_id).name]
info.push ["Department ",@employee.employee_department.name]
info.push ["Joining Date ",@employee.joining_date.strftime("%d %B %Y")]
info.push ["Payslip generated on ",@salary_date]

 pdf.table info, :width => 450,
                :column_widths => {0=>130,1=>150},
                :position => :center,
                :align => { 0 => :left, 1 => :left},
                :border_color => "FFFFFF",
                 :font_size        => 10,
                 :vertical_padding=>1,
                 :position =>52

pdf.move_down(20)

data = Array.new(){Array.new()}

@monthly_payslips.each do |mp|
            category = PayrollCategory.find(mp.payroll_category_id)
           if category.is_deduction == false
                data.push [ category.name, @currency_type.to_s + mp.amount.to_s ]
            end
    end
unless @individual_payslip_category.empty?
    @individual_payslip_category.each do |pc|
        if pc.is_deduction == false
            data.push [pc.name, @currency_type.to_s + pc.amount.to_s]
        end
    end
end
data.push   ["Total Salary", @currency_type.to_s+@net_non_deductionable_amount.to_s]
unless data.empty?
 pdf.table data, :width => 450,
                 :border_color => "000000",
                :column_widths => {0=>300,1=>150},
                :position => :center,
                :headers => ["Salary",""],
                :header_color => "DDDDDD",
                :header_text_color => "97080e",
                :row_colors => ["EEEEEE","FFFFFF"],
                :align => { 0 => :left, 1 => :right}
data = Array.new(){Array.new()}
end
@monthly_payslips.each do |mp|
    category = PayrollCategory.find(mp.payroll_category_id)
       if  category.is_deduction == true
            data.push  [ category.name,@currency_type.to_s + mp.amount.to_s]
        end
end
unless @individual_payslip_category.empty?
    @individual_payslip_category.each do |pc|
        if pc.is_deduction == true
            data.push [pc.name, @currency_type.to_s + pc.amount.to_s]
        end
    end
end
data.push   ["Total Deduction", @currency_type.to_s+@net_deductionable_amount.to_s]
unless data.empty?
pdf.table data, :width => 450,
                :column_widths => {0=>300,1=>150},
                :border_color => "000000",
                :position => :center,
                :headers => ['Deductions',""],
                :header_color => "DDDDDD",
                :header_text_color => "97080e",
                 :row_colors => ["EEEEEE","FFFFFF"],
                :align => { 0 => :left, 1 => :right}
data = Array.new(){Array.new()}
end

data = Array.new(){Array.new()}

data.push  ["Net Salary", @currency_type.to_s+@net_amount.to_s]
pdf.table data, :width => 450,
                :column_widths => {0=>300,1=>150},
                :border_color => "000000",
                :position => :center,
                :headers => ['Total',""],
                :header_color => "DDDDDD",
                :header_text_color => "97080e",
                :row_colors => ["EEEEEE","FFFFFF"],
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