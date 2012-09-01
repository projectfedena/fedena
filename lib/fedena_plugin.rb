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

class FedenaPlugin

  AVAILABLE_MODULES = []
  ADDITIONAL_LINKS = Hash.new{|k,v| k[v] = []}
  REGISTERED_HOOKS = Hash.new{|k,v| k[v] = []}
  FINANCE_CATEGORY = []
  CSS_OVERRIDES = Hash.new{|k,v| k[v] = []}

  def self.register=(plugin_details)
    unless AVAILABLE_MODULES.collect{|mod| mod[:name]}.include?(plugin_details[:name])
      AVAILABLE_MODULES << plugin_details
      ADDITIONAL_LINKS[:student_profile_more_menu] << plugin_details[:student_profile_more_menu] unless plugin_details[:student_profile_more_menu].blank?
      ADDITIONAL_LINKS[:employee_profile_more_menu] << plugin_details[:employee_profile_more_menu] unless plugin_details[:employee_profile_more_menu].blank?
      ADDITIONAL_LINKS[:online_exam_index_link] << plugin_details[:online_exam_index_link] unless plugin_details[:online_exam_index_link].blank?
      ADDITIONAL_LINKS[:instant_fees_index_link] << plugin_details[:instant_fees_index_link] unless plugin_details[:instant_fees_index_link].blank?
      ADDITIONAL_LINKS[:autosuggest_menuitems] << plugin_details[:autosuggest_menuitems] unless plugin_details[:autosuggest_menuitems].blank?
      ADDITIONAL_LINKS[:generic_hook]<<plugin_details[:generic_hook] unless plugin_details[:generic_hook].blank?
      FINANCE_CATEGORY << plugin_details[:finance] unless plugin_details[:finance].blank?
      unless plugin_details[:css_overrides].blank?
        plugin_details[:css_overrides].each do |css|
          CSS_OVERRIDES["#{css[:controller]}_#{css[:action]}"] << plugin_details[:name]
        end
      end
      Authorization::AUTH_DSL_FILES << "#{RAILS_ROOT}/vendor/plugins/#{plugin_details[:name]}/#{plugin_details[:auth_file]}" unless plugin_details[:auth_file].blank?
      if defined? plugin_details[:name].camelize.constantize
        if plugin_details[:name].camelize.constantize.respond_to? "student_profile_hook"
          REGISTERED_HOOKS[:student_profile] << plugin_details[:name]
        end
        if plugin_details[:name].camelize.constantize.respond_to? "application_layout_header"
          REGISTERED_HOOKS[:application_layout_header] << plugin_details[:name]
        end
        if plugin_details[:name].camelize.constantize.respond_to? "general_settings_form"
          REGISTERED_HOOKS[:general_settings_form] << plugin_details[:name]
        end
        if plugin_details[:name].camelize.constantize.respond_to? "general_settings_checkbox"
          REGISTERED_HOOKS[:general_settings_checkbox] << plugin_details[:name]
        end
        if plugin_details[:name].camelize.constantize.respond_to? "dashboard_layout_left_sidebar"
          REGISTERED_HOOKS[:dashboard_layout_left_sidebar] << plugin_details[:name]
        end
      end
    end
  end

  def self.check_dependency(record,action)
    dependency = []
    AVAILABLE_MODULES.each do |mod|
      modu = mod[:name].classify.constantize
      if modu.respond_to?("dependency_check")
        dependency << mod[:name] if modu.send("dependency_check",record,action)
      end      
    end
    dependency
  end
  
end
