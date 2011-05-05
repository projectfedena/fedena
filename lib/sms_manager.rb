# Configure your SMS API settings 
require 'net/http'

class SmsManager
  attr_accessor :recipients, :message

  SMS_URL = 'http://bulksms.mysmsmantra.com:8080/WebSMS/SMSAPI.jsp'
  USERNAME = 'foradian'
  PASSWORD = '1753790267'
  SENDERNAME = 'foradian'

  def initialize(message, recipients)
    @recipients = recipients
    @message = CGI::escape message
  end

  def send_sms
    request = "#{SMS_URL}?username=#{USERNAME}&password=#{PASSWORD}&sendername=#{SENDERNAME}&message=#{@message}&mobileno="

    cur_request = request
    @recipients.each do |recipient|
      if cur_request.length > 1000
        response = Net::HTTP.get_response(URI.parse(URI.encode(cur_request)))
        cur_request = request
      end
      cur_request += ",#{recipient}"
    end

    if request.length < cur_request.length
      response = Net::HTTP.get_response(URI.parse(URI.encode(cur_request)))
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