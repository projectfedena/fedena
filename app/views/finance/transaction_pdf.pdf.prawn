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
data = Array.new(){Array.new()}
pdf.move_down(100)
pdf.text "Finance Transaction Report",  :size=>14
pdf.text "From( #{@start_date})to( #{@end_date})" ,:size => 9

 pdf.move_down(20)
index = 0
income_total = 0
expenses_total = 0

        
unless @hr.nil?
                data .push [ index+=1,'Salary', @salary, ''  ]
end
                data.push [ index+=1, 'Donations', '', @donations_total  ]
                data.push [ index+=1, 'Fees account', '', @transactions_fees  ]
@other_transactions.each_with_index do |t,i|
if t.category.is_income?
                data.push [ i+index, t.title, '', t.amount  ]
                income_total +=t.amount
else
                data.push [ i+index, t.title,  t.amount, '' ]
                expenses_total +=t.amount
end
end
if @grand_total >= 0
                data.push [ '', 'Grand total',  '', @grand_total ]
else
                data.push [ '', 'Grand total',   @grand_total, '' ]
end

pdf.bounding_box([20,580], :width => 500,:height=>550) do
pdf.table data, :width => 500,
  :headers => [ 'Sl no.', 'Particulars', "Expenses( #{currency})","Income( #{currency})"  ],
  :border_color => "000000",
  :header_color => "eeeeee",
  :header_text_color  => "97080e",
  :position => :center,
  :row_colors => ["FFFFFF","DDDDDD"],
  :align => { 0 => :left, 1 => :left,2=>:center,3=>:center}
end

        
    pdf.move_down(30)






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

