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
pdf.text "Fee Defaulters" , :size => 14 ,:align => :center
pdf.move_down(20)
pdf.text "Class :"+@batch.full_name , :size => 14


total_fees = 0

data = Array.new(){Array.new()}
@students.each_with_index do |s, i|
  @fee_collection = FinanceFeeCollection.find(params[:date])
  @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
  @fee_particulars = @fee_category.fees(s)
  total_fees = 0
  @fee_particulars.each do |p|
    total_fees += p.amount
  end
  if s.check_fees_paid(@date) == false
    data.push [ i+1, s.full_name, total_fees  ]
  end
end



pdf.move_down(30)

unless data.empty?
pdf.move_down(30)
pdf.table data, :width => 500,
  :headers => [ 'Sl no.', 'Name', 'Amount'  ],
  :border_color => "000000",
  :header_color => "eeeeee",
  :header_text_color  => "97080e",
  :position => :center,
  :row_colors => ["FFFFFF","DDDDDD"],
  :align => { 0 => :left, 1 => :left}
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

