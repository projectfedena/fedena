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

pdf.move_down(80)
pdf.text "Fee Receipt" , :size => 14 ,:align => :center
pdf.move_down(20)
pdf.text "Name : #{@student.full_name} " , :size => 11
pdf.text "Admission no : #{@student.admission_no}" , :size => 11

total_fees = 0

data = Array.new(){Array.new()}
@fee_particulars.each_with_index do |fee,i|
      data.push  [ i+1, shorten_string(fee.name,20), @currency_type.to_s + " " +fee.amount.to_s  ]
       total_fees += fee.amount
end

            
unless @financefee.transaction_id.nil?
@trans = FinanceTransaction.find(@financefee.transaction_id)
    if @trans.fine_included
                 data.push [ @fee_particulars.size+1, 'Fine', @currency_type.to_s + " " +(@trans.amount.to_f-total_fees).to_s  ]
  total_fees = @trans.amount.to_f
    end
unless @paid_fees.nil?
         paid = 0
        @paid_fees.each do |p|
          paid += p.amount.to_f
            data.push [ @fee_particulars.size+2, 'Partial Payment done on ' + p.transaction_date.to_s, '-' + @currency_type.to_s + " " +(p.amount.to_s)  ]

        end
        total_fees -= paid
      end
end
pdf.move_down(20)
data.push [ 'Amount to Pay', '', @currency_type.to_s + " " +total_fees.to_s ]
pdf.table data, :width => 500,
                :headers => [ 'Sl no.', 'Particulars', 'Amount'  ],
                :border_color => "000000",
                :header_color => "eeeeee",
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

