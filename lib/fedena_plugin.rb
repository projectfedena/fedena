class FedenaPlugin

  AVAILABLE_MODULES = []
  ADDITIONAL_LINKS = Hash.new{|k,v| k[v] = []}
  REGISTERED_HOOKS = Hash.new{|k,v| k[v] = []}
  FINANCE_CATEGORY = []

  def self.register=(plugin_details)
    unless AVAILABLE_MODULES.collect{|mod| mod[:name]}.include?(plugin_details[:name])
      AVAILABLE_MODULES << plugin_details
      ADDITIONAL_LINKS[:student_profile_more_menu] << plugin_details[:student_profile_more_menu] unless plugin_details[:student_profile_more_menu].blank?
      FINANCE_CATEGORY << plugin_details[:finance] unless plugin_details[:finance][:category_name].blank?
      Authorization::AUTH_DSL_FILES << "#{RAILS_ROOT}/vendor/plugins/#{plugin_details[:name]}/#{plugin_details[:auth_file]}"
      if defined? plugin_details[:name].camelize.constantize
        if plugin_details[:name].camelize.constantize.respond_to? "student_profile_hook"
          REGISTERED_HOOKS[:student_profile] << plugin_details[:name]
        end
      end
    end
  end
end
