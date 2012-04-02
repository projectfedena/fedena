FEDENA_DEFAULTS = {
  :company_name => 'Fedena',
  :company_url  => 'http://www.projectfedena.org'
}

USER_SETTINGS = {}

if File.exists?("#{RAILS_ROOT}/config/company_details.yml")
  company_settings = YAML.load_file(File.join(RAILS_ROOT,"config","company_details.yml"))
  USER_SETTINGS = {:company_name => company_settings['company_details']['company_name'],
                   :company_url  => company_settings['company_details']['company_url']
  }
end

FEDENA_SETTINGS = FEDENA_DEFAULTS.merge!(USER_SETTINGS)

 