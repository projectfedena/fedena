# Configure your SMS API settings
require 'net/http'
require 'yaml'
require 'translator'

class SmsManager
  attr_accessor :recipients, :message

  def initialize(message, recipients)
    @recipients = recipients
    @message = URI.encode(message)
    if File.exists?("#{RAILS_ROOT}/config/sms_settings.yml")
      @config = YAML.load_file(File.join(RAILS_ROOT,"config","sms_settings.yml"))
    end
    unless @config.blank?
      @sendername = @config['sms_settings']['sendername']
      @sms_url = @config['sms_settings']['host_url']
      @username = @config['sms_settings']['username']
      @password = @config['sms_settings']['password']
      @success_code = @config['sms_settings']['success_code']
    end
  end

  def send_sms
    return "#{t('sms_configuration_not_found')}" if @config.blank?

    request = "#{@sms_url}?username=#{@username}&password=#{@password}&sendername=#{@sendername}&message=#{@message}&mobileno="

    cur_request = request
    @recipients.each do |recipient|
      if cur_request.length > 1000
        response = Net::HTTP.get_response(URI.parse(cur_request))
        cur_request = request
      end
      cur_request += ",#{recipient}"
    end

    if request.length < cur_request.length
      response = Net::HTTP.get_response(URI.parse(cur_request))
    end
    cur_request
    #response_string = response.split
    
    unless response.body.index(@success_code).nil?
      #    if response.body =~ /Your message is successfully/
      sms_count = Configuration.find_by_config_key("TotalSmsCount")
      new_count = sms_count.config_value.to_i+@recipients.size
      Configuration.update(sms_count.id,:config_value=>new_count.to_s)
    end

    if response.body.nil?
      return 'sorry'
    else
      return response.body.index(@success_code).nil? ? response.body : '0000'
    end

  end

end