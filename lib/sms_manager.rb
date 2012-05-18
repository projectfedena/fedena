# Configure your SMS API settings
require 'net/http'
require 'yaml'
require 'translator'

class SmsManager
  attr_accessor :recipients, :message

  def initialize(message, recipients)
    @recipients = recipients
    @message = message
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

  def perform
    if @config.present?
      message_log = SmsMessage.new(:body=> @message)
      message_log.save
      encoded_message = URI.encode(@message)
      request = "#{@sms_url}?username=#{@username}&password=#{@password}&sendername=#{@sendername}&message=#{encoded_message}&mobileno="
      @recipients.each do |recipient|
        cur_request = request
        cur_request += "#{recipient}"
        begin
          response = Net::HTTP.get_response(URI.parse(cur_request))
          if response.body
            message_log.sms_logs.create(:mobile=>recipient,:gateway_response=>response.body)
            if response.body.to_s =~ Regexp.new(@success_code)
              sms_count = Configuration.find_by_config_key("TotalSmsCount")
              new_count = sms_count.config_value.to_i + 1
              sms_count.update_attributes(:config_value=>new_count)
            end
          end
        rescue Timeout::Error => e
          message_log.sms_logs.create(:mobile=>recipient,:gateway_response=>e.message)
        rescue Errno::ECONNREFUSED => e
          message_log.sms_logs.create(:mobile=>recipient,:gateway_response=>e.message)
        end
      end
    end
  end
end