class XmlController < ApplicationController
  require "rexml/document"

  before_filter :login_required
  filter_access_to :all


  def index
    
  end

  def settings
    @xml = Xml.get_multiple_finance_as_hash ['Salary', 'Fee', 'Donation']
    if request.post?
      Xml.set_ledger_name(params[:xml_settings])
      flash[:notice] = "XML settings updated successfully"
      redirect_to  :action => "settings"
    end
  end
  #enevelope = REXML::Element.new "ENVELOPE"
  #    header = enevelope.add_element "HEADER"
  #    tally_request = header.add_element "TALLYREQUEST"
  #    tally_request.text = "Import Data"
  #    body = enevelope.add_element "BODY"
  #    import_data = body.add_element "IMPORTDATA"
  #    requestdesc = import_data.add_element "REQUESTDESC"
  #    report_name = requestdesc.add_element "REPORTNAME"
  #    report_name.text = "All Masters"
  #    static_variables = requestdesc.add_element "STATICVARIABLES"
  #    svcurrentcompany = static_variables.add_element "SVCURRENTCOMPANY"
  #    svcurrentcompany.text = @institution.config_value
  #    requestdata = import_data.add_element "REQUESTDATA"
  #
  #    while count<2
  #      tally_message = requestdata.add_element "TALLYMESSAGE"
  #      currency = tally_message.add_element "CURRENCY"
  #      currency.add_attribute("NAME",@currency.config_value)
#      currency.add_attribute("RESERVEDNAME","")
  #      additional_name = currency.add_element("ADDITIONALNAME")
  #      additional_name.text  = @currency.config_value
  #      expanded_name = currency.add_element("EXPANDEDSYMBOL")
  #      expanded_name.text = @currency.config_value
  #      decimal_symbol = currency.add_element("DECIMALNAME")
  def create_xml
    if request.post?
      @institution = Configuration.find_by_config_key("InstitutionName")
      @currency = Configuration.find_by_config_key("CurrencyType")
      @start_date = params[:xml][:start_date].to_date
      @end_date = params[:xml][:end_date].to_date
      employees = Employee.find(:all)
      
      @salaries = []
      @months = MonthlyPayslip.find(:all,:select =>"distinct salary_date" ,:order => 'salary_date desc', :conditions => ["salary_date >= '#{@start_date}' and salary_date <= '#{@end_date}' and is_approved = 1"])
      @months.each do |m|
        @salary = Employee.total_employees_salary(employees, m.salary_date, m.salary_date)
        @salaries.push @salary
      end
      transactions = FinanceTransaction.find(:all,
        :order => 'created_at desc', :conditions => ["created_at >= '#{@start_date}' and created_at <= '#{@end_date}'"])

      count = 0
      category = [1,2,3]
      file = File.new("Tally.xml",'w')
      doc = REXML::Document.new

      enevelope = REXML::Element.new "ENVELOPE"
      header = enevelope.add_element "HEADER"
      tally_request = header.add_element "TALLYREQUEST"
      tally_request.text = "Import Data"
      body = enevelope.add_element "BODY"
      import_data = body.add_element "IMPORTDATA"
      requestdesc = import_data.add_element "REQUESTDESC"
      report_name = requestdesc.add_element "REPORTNAME"
      report_name.text = "All Masters"
      static_variables = requestdesc.add_element "STATICVARIABLES"
      svcurrentcompany = static_variables.add_element "SVCURRENTCOMPANY"
      svcurrentcompany.text = @institution.config_value
      requestdata = import_data.add_element "REQUESTDATA"
      transactions.each do |trans|
        if category.include?(trans.category_id)
          if trans.category_id == 3
            fee = FinanceFee.find_by_transaction_id(trans.id)
            student = Student.find(fee.student_id)
            collection = FinanceFeeCollection.find(fee.fee_collection_id)
            nar = "Fee recieved from #{student.full_name} for #{collection.name} - #{trans.title} "
          else
            nar = "#{trans.title} - #{trans.description}"
          end
          tally_message = requestdata.add_element "TALLYMESSAGE"
          tally_message.add_attribute("xmlns:UDF","TallyUDF")
          count += 1
     
          @ledger = Xml.find_by_finance_name(trans.category.name)
          if trans.category.is_income?
            voucher = tally_message.add_element "VOUCHER"
            voucher.add_attribute("REMOTEID","")
            voucher.add_attribute("VCHTYPE","Receipt")
            voucher.add_attribute("ACTION","Create")
            date = voucher.add_element "DATE"
            date.text = trans.created_at.strftime("%Y%m%d")
            #            date.text = "20090901"
            guid = voucher.add_element "GUID"
            guid.text = ""
            narration = voucher.add_element "NARRATION"
            narration.text = "#{nar}"
            vouchertype = voucher.add_element "VOUCHERTYPENAME"
            vouchertype.text = "Receipt"
            vouchernumber = voucher.add_element "VOUCHERNUMBER"
            vouchernumber.text = count
            partyledgername = voucher.add_element "PARTYLEDGERNAME"
            partyledgername.text = "Cash"
            form_issue_type = voucher.add_element "CSTFORMISSUETYPE"
            form_rcv_type = voucher.add_element "CSTFORMRECVTYPE"
            paymnt_type = voucher.add_element "FBTPAYMENTTYPE"
            paymnt_type.text = "Default"
            gst_class = voucher.add_element "VCHGSTCLASS"
            actual_qty = voucher.add_element "DIFFACTUALQTY"
            actual_qty.text = "No"
            audited = voucher.add_element "AUDITED"
            audited.text = "No"
            job_costing = voucher.add_element "FORJOBCOSTING"
            job_costing.text = "No"
            is_optional = voucher.add_element "ISOPTIONAL"
            is_optional.text = "No"
            effective_date = voucher.add_element "EFFECTIVEDATE"
            effective_date.text = trans.created_at.strftime("%Y%m%d")
            #            effective_date.text = "20090901"
            use_for_interest = voucher.add_element "USEFORINTEREST"
            use_for_interest.text = "No"
            use_for_gain_loss = voucher.add_element "USEFORGAINLOSS"
            use_for_gain_loss.text = "No"
            use_for_godown_transfer = voucher.add_element "USEFORGODOWNTRANSFER"
            use_for_godown_transfer.text = "No"
            use_for_compound = voucher.add_element "USEFORCOMPOUND"
            use_for_compound.text = "No"
            alter_id = voucher.add_element "ALTERID"
            alter_id.text = count
            excise_opening = voucher.add_element "EXCISEOPENING"
            excise_opening.text = "No"
            is_cancelled = voucher.add_element "ISCANCELLED"
            is_cancelled.text = "No"
            has_cash_flow = voucher.add_element "HASCASHFLOW"
            has_cash_flow.text = "Yes"
            is_posted_date = voucher.add_element "ISPOSTDATED"
            is_posted_date.text = "No"
            use_tracking_number = voucher.add_element "USETRACKINGNUMBER"
            use_tracking_number.text = "No"
            is_invoice = voucher.add_element "ISINVOICE"
            is_invoice.text = "No"
            mfg_journal = voucher.add_element "MFGJOURNAL"
            mfg_journal.text = "No"
            has_discounts = voucher.add_element "HASDISCOUNTS"
            has_discounts.text = "No"
            as_payslip = voucher.add_element "ASPAYSLIP"
            as_payslip.text = "No"
            is_deleted = voucher.add_element "ISDELETED"
            is_deleted.text = "No"
            as_original = voucher.add_element "ASORIGINAL"
            as_original.text = "No"
            all_ledger_entry = voucher.add_element "ALLLEDGERENTRIES.LIST"
            ledger_name = all_ledger_entry.add_element "LEDGERNAME"
            ledger_name.text = @ledger.ledger_name
            gst_class = all_ledger_entry.add_element "GSTCLASS"
            is_deemed_positive = all_ledger_entry.add_element "ISDEEMEDPOSITIVE"
            is_deemed_positive.text = "No"
            ledger_from_item = all_ledger_entry.add_element "LEDGERFROMITEM"
            ledger_from_item.text = "No"
            remove_zero_entries = all_ledger_entry.add_element "REMOVEZEROENTRIES"
            remove_zero_entries.text = "No"
            is_party_ledger = all_ledger_entry.add_element "ISPARTYLEDGER"
            is_party_ledger.text = "No"
            amount = all_ledger_entry.add_element "AMOUNT"
            amount.text = "#{trans.amount}"
            all_ledger_entry2 = voucher.add_element "ALLLEDGERENTRIES.LIST"
            ledger_name2 = all_ledger_entry2.add_element "LEDGERNAME"
            ledger_name2.text = "Cash"
            gst_class2 = all_ledger_entry2.add_element "GSTCLASS"
            is_deemed_positive2 = all_ledger_entry2.add_element "ISDEEMEDPOSITIVE"
            is_deemed_positive2.text = "Yes"
            ledger_from_item2 = all_ledger_entry2.add_element "LEDGERFROMITEM"
            ledger_from_item2.text = "No"
            remove_zero_entries2 = all_ledger_entry2.add_element "REMOVEZEROENTRIES"
            remove_zero_entries2.text = "No"
            is_party_ledger2 = all_ledger_entry2.add_element "ISPARTYLEDGER"
            is_party_ledger2.text = "Yes"
            amount2 = all_ledger_entry2.add_element "AMOUNT"
            amount2.text = "-#{trans.amount}"

            #            account = enevelope.add_element "DSPVCHLEDACCOUNT"
            #            account.text = @ledger.ledger_name
            #            namefield = enevelope.add_element "NAMEFIELD"
            #            infofield = enevelope.add_element "INFOFIELD"
            #            vouchertype = enevelope.add_element "DSPVCHTYPE"
            #            vouchertype.text = "Rcpt"
            #            voucheramt = enevelope.add_element "DSPVCHDRAMT"
            #            voucheramt.text = "-#{trans.amount}"
            #            voucheramt = enevelope.add_element "DSPVCHDRAMT"
          else
            voucher = tally_message.add_element "VOUCHER"
            voucher.add_attribute("REMOTEID","")
            voucher.add_attribute("VCHTYPE","Payment")
            voucher.add_attribute("ACTION","Create")
            date = voucher.add_element "DATE"
            date.text = trans.created_at.strftime("%Y%m%d")
            #            date.text = "20090901"
            guid = voucher.add_element "GUID"
            guid.text = ""
            narration = voucher.add_element "NARRATION"
            narration.text = ""
            vouchertype = voucher.add_element "VOUCHERTYPENAME"
            vouchertype.text = "Payment"
            vouchernumber = voucher.add_element "VOUCHERNUMBER"
            vouchernumber.text = i+1
            partyledgername = voucher.add_element "PARTYLEDGERNAME"
            partyledgername.text = "Cash"
            form_issue_type = voucher.add_element "CSTFORMISSUETYPE"
            form_rcv_type = voucher.add_element "CSTFORMRECVTYPE"
            paymnt_type = voucher.add_element "FBTPAYMENTTYPE"
            paymnt_type.text = "Default"
            gst_class = voucher.add_element "VCHGSTCLASS"
            actual_qty = voucher.add_element "DIFFACTUALQTY"
            actual_qty.text = "No"
            audited = voucher.add_element "AUDITED"
            audited.text = "No"
            job_costing = voucher.add_element "FORJOBCOSTING"
            job_costing.text = "No"
            is_optional = voucher.add_element "ISOPTIONAL"
            is_optional.text = "No"
            effective_date = voucher.add_element "EFFECTIVEDATE"
            effective_date.text = trans.created_at.strftime("%Y%m%d")
            #            effective_date.text = "20090901"
            use_for_interest = voucher.add_element "USEFORINTEREST"
            use_for_interest.text = "No"
            use_for_gain_loss = voucher.add_element "USEFORGAINLOSS"
            use_for_gain_loss.text = "No"
            use_for_godown_transfer = voucher.add_element "USEFORGODOWNTRANSFER"
            use_for_godown_transfer.text = "No"
            use_for_compound = voucher.add_element "USEFORCOMPOUND"
            use_for_compound.text = "No"
            alter_id = voucher.add_element "ALTERID"
            alter_id.text = i+1
            excise_opening = voucher.add_element "EXCISEOPENING"
            excise_opening.text = "No"
            is_cancelled = voucher.add_element "ISCANCELLED"
            is_cancelled.text = "No"
            has_cash_flow = voucher.add_element "HASCASHFLOW"
            has_cash_flow.text = "Yes"
            is_posted_date = voucher.add_element "ISPOSTDATED"
            is_posted_date.text = "No"
            use_tracking_number = voucher.add_element "USETRACKINGNUMBER"
            use_tracking_number.text = "No"
            is_invoice = voucher.add_element "ISINVOICE"
            is_invoice.text = "No"
            mfg_journal = voucher.add_element "MFGJOURNAL"
            mfg_journal.text = "No"
            has_discounts = voucher.add_element "HASDISCOUNTS"
            has_discounts.text = "No"
            as_payslip = voucher.add_element "ASPAYSLIP"
            as_payslip.text = "No"
            is_deleted = voucher.add_element "ISDELETED"
            is_deleted.text = "No"
            as_original = voucher.add_element "ASORIGINAL"
            as_original.text = "No"
            all_ledger_entry = voucher.add_element "ALLLEDGERENTRIES.LIST"
            ledger_name = all_ledger_entry.add_element "LEDGERNAME"
            ledger_name.text = @ledger.ledger_name
            gst_class = all_ledger_entry.add_element "GSTCLASS"
            is_deemed_positive = all_ledger_entry.add_element "ISDEEMEDPOSITIVE"
            is_deemed_positive.text = "No"
            ledger_from_item = all_ledger_entry.add_element "LEDGERFROMITEM"
            ledger_from_item.text = "No"
            remove_zero_entries = all_ledger_entry.add_element "REMOVEZEROENTRIES"
            remove_zero_entries.text = "No"
            is_party_ledger = all_ledger_entry.add_element "ISPARTYLEDGER"
            is_party_ledger.text = "No"
            amount = all_ledger_entry.add_element "AMOUNT"
            amount.text = "-#{trans.amount}"
            all_ledger_entry2 = voucher.add_element "ALLLEDGERENTRIES.LIST"
            ledger_name2 = all_ledger_entry2.add_element "LEDGERNAME"
            ledger_name2.text = "Cash"
            gst_class2 = all_ledger_entry2.add_element "GSTCLASS"
            is_deemed_positive2 = all_ledger_entry2.add_element "ISDEEMEDPOSITIVE"
            is_deemed_positive2.text = "Yes"
            ledger_from_item2 = all_ledger_entry2.add_element "LEDGERFROMITEM"
            ledger_from_item2.text = "No"
            remove_zero_entries2 = all_ledger_entry2.add_element "REMOVEZEROENTRIES"
            remove_zero_entries2.text = "No"
            is_party_ledger2 = all_ledger_entry2.add_element "ISPARTYLEDGER"
            is_party_ledger2.text = "Yes"
            amount2 = all_ledger_entry2.add_element "AMOUNT"
            amount2.text = "#{trans.amount}"
            #            date = enevelope.add_element "DSPVCHDATE"
            #            date.text = trans.created_at.strftime("%d-%m-%y")
            #            account = enevelope.add_element "DSPVCHLEDACCOUNT"
            #            account.text = @ledger.ledger_name
            #            namefield = enevelope.add_element "NAMEFIELD"
            #            infofield = enevelope.add_element "INFOFIELD"
            #            vouchertype = enevelope.add_element "DSPVCHTYPE"
            #            vouchertype.text = "Pymt"
            #            voucheramt = enevelope.add_element "DSPVCHDRAMT"
            #            voucheramt.text = trans.amount
            #            voucheramt = enevelope.add_element "DSPVCHDRAMT"
          end
        end
      end
      @salaries.each do |s|
        count += 1
        @ledger = Xml.find_by_finance_name("Salary")
        tally_message = requestdata.add_element "TALLYMESSAGE"
        tally_message.add_attribute("xmlns:UDF","TallyUDF")
        voucher = tally_message.add_element "VOUCHER"
        voucher.add_attribute("REMOTEID","")
        voucher.add_attribute("VCHTYPE","Payment")
        voucher.add_attribute("ACTION","Create")
        date = voucher.add_element "DATE"
        date.text = @start_date.beginning_of_month.strftime("%Y%m%d")
        #            date.text = "20090901"
        guid = voucher.add_element "GUID"
        guid.text = ""
        narration = voucher.add_element "NARRATION"
        narration.text = "Salary given"
        vouchertype = voucher.add_element "VOUCHERTYPENAME"
        vouchertype.text = "Payment"
        vouchernumber = voucher.add_element "VOUCHERNUMBER"
        vouchernumber.text = count
        partyledgername = voucher.add_element "PARTYLEDGERNAME"
        partyledgername.text = "Cash"
        form_issue_type = voucher.add_element "CSTFORMISSUETYPE"
        form_rcv_type = voucher.add_element "CSTFORMRECVTYPE"
        paymnt_type = voucher.add_element "FBTPAYMENTTYPE"
        paymnt_type.text = "Default"
        gst_class = voucher.add_element "VCHGSTCLASS"
        actual_qty = voucher.add_element "DIFFACTUALQTY"
        actual_qty.text = "No"
        audited = voucher.add_element "AUDITED"
        audited.text = "No"
        job_costing = voucher.add_element "FORJOBCOSTING"
        job_costing.text = "No"
        is_optional = voucher.add_element "ISOPTIONAL"
        is_optional.text = "No"
        effective_date = voucher.add_element "EFFECTIVEDATE"
        effective_date.text = @start_date.beginning_of_month.strftime("%Y%m%d")
        #            effective_date.text = "20090901"
        use_for_interest = voucher.add_element "USEFORINTEREST"
        use_for_interest.text = "No"
        use_for_gain_loss = voucher.add_element "USEFORGAINLOSS"
        use_for_gain_loss.text = "No"
        use_for_godown_transfer = voucher.add_element "USEFORGODOWNTRANSFER"
        use_for_godown_transfer.text = "No"
        use_for_compound = voucher.add_element "USEFORCOMPOUND"
        use_for_compound.text = "No"
        alter_id = voucher.add_element "ALTERID"
        alter_id.text = count
        excise_opening = voucher.add_element "EXCISEOPENING"
        excise_opening.text = "No"
        is_cancelled = voucher.add_element "ISCANCELLED"
        is_cancelled.text = "No"
        has_cash_flow = voucher.add_element "HASCASHFLOW"
        has_cash_flow.text = "Yes"
        is_posted_date = voucher.add_element "ISPOSTDATED"
        is_posted_date.text = "No"
        use_tracking_number = voucher.add_element "USETRACKINGNUMBER"
        use_tracking_number.text = "No"
        is_invoice = voucher.add_element "ISINVOICE"
        is_invoice.text = "No"
        mfg_journal = voucher.add_element "MFGJOURNAL"
        mfg_journal.text = "No"
        has_discounts = voucher.add_element "HASDISCOUNTS"
        has_discounts.text = "No"
        as_payslip = voucher.add_element "ASPAYSLIP"
        as_payslip.text = "No"
        is_deleted = voucher.add_element "ISDELETED"
        is_deleted.text = "No"
        as_original = voucher.add_element "ASORIGINAL"
        as_original.text = "No"
        all_ledger_entry = voucher.add_element "ALLLEDGERENTRIES.LIST"
        ledger_name = all_ledger_entry.add_element "LEDGERNAME"
        ledger_name.text = @ledger.ledger_name
        gst_class = all_ledger_entry.add_element "GSTCLASS"
        is_deemed_positive = all_ledger_entry.add_element "ISDEEMEDPOSITIVE"
        is_deemed_positive.text = "No"
        ledger_from_item = all_ledger_entry.add_element "LEDGERFROMITEM"
        ledger_from_item.text = "No"
        remove_zero_entries = all_ledger_entry.add_element "REMOVEZEROENTRIES"
        remove_zero_entries.text = "No"
        is_party_ledger = all_ledger_entry.add_element "ISPARTYLEDGER"
        is_party_ledger.text = "No"
        amount = all_ledger_entry.add_element "AMOUNT"
        amount.text = "-#{s}"
        all_ledger_entry2 = voucher.add_element "ALLLEDGERENTRIES.LIST"
        ledger_name2 = all_ledger_entry2.add_element "LEDGERNAME"
        ledger_name2.text = "Cash"
        gst_class2 = all_ledger_entry2.add_element "GSTCLASS"
        is_deemed_positive2 = all_ledger_entry2.add_element "ISDEEMEDPOSITIVE"
        is_deemed_positive2.text = "Yes"
        ledger_from_item2 = all_ledger_entry2.add_element "LEDGERFROMITEM"
        ledger_from_item2.text = "No"
        remove_zero_entries2 = all_ledger_entry2.add_element "REMOVEZEROENTRIES"
        remove_zero_entries2.text = "No"
        is_party_ledger2 = all_ledger_entry2.add_element "ISPARTYLEDGER"
        is_party_ledger2.text = "Yes"
        amount2 = all_ledger_entry2.add_element "AMOUNT"
        amount2.text = "#{s}"
        #        date = enevelope.add_element "DSPVCHDATE"
        #        date.text = @start_date.beginning_of_month.strftime("%d-%m-%y")
        #        account = enevelope.add_element "DSPVCHLEDACCOUNT"
        #        account.text = @ledger.ledger_name
        #        namefield = enevelope.add_element "NAMEFIELD"
        #        infofield = enevelope.add_element "INFOFIELD"
        #        vouchertype = enevelope.add_element "DSPVCHTYPE"
        #        vouchertype.text = "Pymt"
        #        voucheramt = enevelope.add_element "DSPVCHDRAMT"
        #        voucheramt.text = s
        #        voucheramt = enevelope.add_element "DSPVCHDRAMT"
        @start_date = @start_date+1.month
      end
    
      #    enevelope = REXML::Element.new "ENVELOPE"
      #    header = enevelope.add_element "HEADER"
      #    tally_request = header.add_element "TALLYREQUEST"
      #    tally_request.text = "Import Data"
      #    body = enevelope.add_element "BODY"
      #    import_data = body.add_element "IMPORTDATA"
      #    requestdesc = import_data.add_element "REQUESTDESC"
      #    report_name = requestdesc.add_element "REPORTNAME"
      #    report_name.text = "All Masters"
      #    static_variables = requestdesc.add_element "STATICVARIABLES"
      #    svcurrentcompany = static_variables.add_element "SVCURRENTCOMPANY"
      #    svcurrentcompany.text = @institution.config_value
      #    requestdata = import_data.add_element "REQUESTDATA"
      #
      #    while count<2
      #      tally_message = requestdata.add_element "TALLYMESSAGE"
      #      currency = tally_message.add_element "CURRENCY"
      #      currency.add_attribute("NAME",@currency.config_value)
      #      currency.add_attribute("RESERVEDNAME","")
      #      additional_name = currency.add_element("ADDITIONALNAME")
      #      additional_name.text  = @currency.config_value
      #      expanded_name = currency.add_element("EXPANDEDSYMBOL")
      #      expanded_name.text = @currency.config_value
      #      decimal_symbol = currency.add_element("DECIMALNAME")
      #      decimal_symbol.text ="No"
      #      original_name = currency.add_element("ORIGINALNAME")
      #      original_name.text = @currency.config_value
      #      is_suffix = currency.add_element("ISSUFFIX")
      #      is_suffix.text = "No"
      #      has_space = currency.add_element("HASSPACE")
      #      has_space.text = "Yes"
      #      in_millions = currency.add_element("INMILLIONS")
      #      in_millions.text = "No"
      #      decimal_places = currency.add_element("DECIMALSPLACES")
      #      decimal_places.text = "2"
      #      decimal_places_for_printing = currency.add_element("DECIMALPLACESFORPRINTING")
      #      decimal_places_for_printing.text = "2"
      #      count += 1
      #    end

      doc.add_element enevelope
      file.puts doc
      file.close

      send_file "Tally.xml", :type=>"xml"

    end
  end
end
