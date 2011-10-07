class FedenaPlugin

  AVAILABLE_MODULES = []

  def self.register=(plugin_details)
    unless AVAILABLE_MODULES.collect{|mod| mod[:name]}.include?(plugin_details[:name])
      AVAILABLE_MODULES << plugin_details
      Authorization::AUTH_DSL_FILES << "#{RAILS_ROOT}/vendor/plugins/#{plugin_details[:name]}/#{plugin_details[:auth_file]}"
    end
  end
end

