# Configure your SMS API settings
require 'net/http'
require 'yaml'

class SmsManager
  attr_accessor :recipients, :message

  def initialize(message, recipients)
    @recipients = recipients
    @message = URI.encode(message)
    @config = YAML.load_file(File.join(RAILS_ROOT,"config","sms_settings.yml"))
    unless @config.blank?
      @sendername = @config['sms_settings']['sendername']
      @sms_url = @config['sms_settings']['host_url']
      @username = @config['sms_settings']['username']
      @password = @config['sms_settings']['password']
    end
  end

  def send_sms
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
    if response.body =~ /Your message is successfully/
      sms_count = Configuration.find_by_config_key("TotalSmsCount")
      new_count = sms_count.config_value.to_i+@recipients.size
      Configuration.update(sms_count.id,:config_value=>new_count.to_s)
    end
  end

end