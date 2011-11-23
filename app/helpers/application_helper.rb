#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

module ApplicationHelper
  def get_stylesheets
    @direction = (rtl?) ? 'rtl/' : ''
    stylesheets = [] unless stylesheets
    ["#{@direction}#{controller.controller_path}/#{controller.action_name}"].each do |ss|
      stylesheets << ss
    end
    plugin_css_overrides = FedenaPlugin::CSS_OVERRIDES["#{controller.controller_path}_#{controller.action_name}"]
    stylesheets << plugin_css_overrides.collect{|p| "#{@direction}plugin_css/#{p}"}
  end

  def observe_fields(fields, options)
	  with = ""                          #prepare a value of the :with parameter
	  for field in fields
		  with += "'"
		  with += "&" if field != fields.first
		  with += field + "='+escape($('" + field + "').value)"
		  with += " + " if field != fields.last
	  end

	  ret = "";      #generate a call of the observer_field helper for each field
	  for field in fields
		  ret += observe_field(field,	options.merge( { :with => with }))
	  end
	  ret
  end

  def shorten_string(string, count)
    if string.length >= count
      shortened = string[0, count]
      splitted = shortened.split(/\s/)
      words = splitted.length
      splitted[0, words-1].join(" ") + ' ...'
    else
      string
    end
  end

  def currency
    Configuration.find_by_config_key("CurrencyType").config_value
  end

  def pdf_image_tag(image, options = {})
    options[:src] = File.expand_path(RAILS_ROOT) + "/public/images"+ image
    tag(:img, options)
  end

  def available_language_options
    options = []
    AVAILABLE_LANGUAGES.each do |locale, language|
      options << [language, locale]
    end
    options.sort_by { |o| o[0] }
  end

  def rtl?
    @rtl ||= RTL_LANGUAGES.include? I18n.locale.to_sym
  end
  def autosuggest_menuitems
    menu_items = []   
    default = [
               {:menu_type => 'link' ,:label => t('autosuggest_menu.student_admission'),:value => {:controller => :student,:action => :admission1}}, 
               {:menu_type => 'link' ,:label => t('autosuggest_menu.employee_admission'),:value =>{:controller => :employee,:action => :admission1}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.exam'),:value =>{:controller => :exam,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.set_grading_levels'),:value =>{:controller => :grading_levels,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.exam_management'),:value =>{:controller => :exam,:action => :create_exam}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.additional_exams'),:value =>{:controller => :additional_exam,:action => :create_additional_exam}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.exam_wise_report'),:value =>{:controller => :exam,:action => :exam_wise_report}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.subject_wise_report'),:value =>{:controller => :exam,:action => :subject_wise_report}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.grouped_exam_report'),:value =>{:controller => :exam,:action => :grouped_exam_report}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.news'),:value =>{:controller => :news,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.event'),:value =>{:controller => :event,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_news'),:value =>{:controller => :news,:action => :all}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.add_news'),:value =>{:controller => :news,:action => :add}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.employee'),:value =>{:controller => :employee,:action => :hr}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.employee_settings'),:value =>{:controller => :employee,:action => :settings}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.employee_subject_association'),:value =>{:controller => :employee,:action => :subject_assignment}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.employee_leave_management'),:value =>{:controller => :employee,:action => :employee_attendance}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.add_leave_type'),:value =>{:controller => :employee_attendance,:action => :add_leave_types}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.attendance_register'),:value =>{:controller => :employee_attendances,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.attendance_report'),:value =>{:controller => :employee_attendance,:action => :report}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.reset_leave'),:value =>{:controller => :employee_attendance,:action => :manual_reset}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.empolyee_payslip'),:value =>{:controller => :employee,:action => :payslip}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.department_wise_payslip'),:value =>{:controller => :employee,:action => :department_payslip}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.finance'),:value =>{:controller => :finance,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.manage_fees'),:value =>{:controller => :finance,:action => :fees_index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.master_fees'),:value =>{:controller => :finance,:action => :master_fees}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.additional_fees'),:value =>{:controller => :finance,:action => :additional_fees}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_additional_fees'),:value =>{:controller => :finance,:action => :additional_fees_list}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.create_additional_fees'),:value =>{:controller => :finance,:action => :additional_fees_create_form}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.fees_collection'),:value =>{:controller => :finance,:action => :fee_collection}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.fees_submission_by_course'),:value =>{:controller => :finance,:action => :fees_submission_batch}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.fees_submission_for_each_student'),:value =>{:controller => :finance,:action => :fees_student_search}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.finance_categories'),:value =>{:controller => :finance,:action => :categories}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.transactions'),:value =>{:controller => :finance,:action => :transactions}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.add_expense'),:value =>{:controller => :finance,:action => :expense_create}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.expense_list'),:value =>{:controller => :finance,:action => :expense_list}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.add_income'),:value =>{:controller => :finance,:action => :income_create}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.income_list'),:value =>{:controller => :finance,:action => :income_list}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.transaction_report'),:value =>{:controller => :finance,:action => :monthly_report}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.compare_transactions'),:value =>{:controller => :finance,:action => :compare_report}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.donations'),:value =>{:controller => :finance,:action => :donation}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.donors'),:value =>{:controller => :finance,:action => :donors}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.automatic_transactions'),:value =>{:controller => :finance,:action => :automatic_transactions}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_payslip'),:value =>{:controller => :finance,:action => :view_monthly_payslip}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.asset'),:value =>{:controller => :finance,:action => :asset}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_assets'),:value =>{:controller => :finance,:action => :view_asset}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.liability'),:value =>{:controller => :finance,:action => :liability}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_liability'),:value =>{:controller => :finance,:action => :view_liability}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.tally_settings'),:value =>{:controller => :xml,:action => :settings}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.export_for_tally'),:value =>{:controller => :xml,:action => :create_xml}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.manage_users'),:value =>{:controller => :user,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_users'),:value =>{:controller => :user,:action => :all}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.add_users'),:value =>{:controller => :user,:action => :create}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.timetable'),:value =>{:controller => :timetable,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.create_timetable'),:value =>{:controller => :timetable,:action => :select_class2}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.set_class_timings'),:value =>{:controller => :class_timings,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_timetables'),:value =>{:controller => :timetable,:action => :view}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.institutional_timetable'),:value =>{:controller => :timetable,:action => :timetable}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.create_weekdays'),:value =>{:controller => :weekday,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.configuartion_home'),:value =>{:controller => :configuration,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.manage_course'),:value =>{:controller => :courses,:action => :manage_course}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.manage_batch'),:value =>{:controller => :courses,:action => :manage_batches}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.add_course'),:value =>{:controller => :courses,:action => :new}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.batch_transfers'),:value =>{:controller => :batch_transfers,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.manage_student_category'),:value =>{:controller => :student,:action => :categories}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.manage_subjects'),:value =>{:controller => :subjects,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.general_settings'),:value =>{:controller => :configuration,:action => :settings}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.add_admission_additional_detail'),:value =>{:controller => :student,:action => :add_additional_details}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.student_attendance'),:value =>{:controller => :student_attendance,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.attendance_register'),:value =>{:controller => :attendances,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.attendance_report'),:value =>{:controller => :attendance_reports,:action => :index}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.view_students'),:value =>{:controller => :student,:action => :view_all}},
               {:menu_type => 'link' ,:label => t('autosuggest_menu.student_advanced_search'),:value =>{:controller => :student,:action => :advanced_search}}
              ]
    (default + FedenaPlugin::ADDITIONAL_LINKS[:autosuggest_menuitems]).each do |plugin_menu_item|
      link = plugin_menu_item[:value]
      if permitted_to? link[:action],link[:controller]
        menu_items << {
          :menu_type => plugin_menu_item[:menu_type],
          :label => plugin_menu_item[:label],
          :value => url_for(plugin_menu_item[:value])
        }
      end
    end
    menu_items.to_json
  end
end
