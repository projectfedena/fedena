require 'digest/sha1'

module OpenFlashChart
  module Controller
    def open_flash_chart_object(width, height, url, use_swfobject=true, base="/", swf_file_name="open-flash-chart.swf")
      get_object_values(url)
      get_html(@ofc_url, @div_name, base, swf_file_name, width, height, @protocol, @obj_id)
    end

    # if you want the div name back for working with js, this is the ticket
    def open_flash_chart_object_and_div_name(width, height, url, use_swfobject=true, base="/", swf_file_name="open-flash-chart.swf")
      get_object_values(url)
      html = get_html(@ofc_url, @div_name, base, swf_file_name, width, height, @protocol, @obj_id)
      return [html, @div_name]
    end

    def open_flash_chart_object_from_hash(url, options={})
      get_object_values(url)
      get_html(@ofc_url,
               options[:div_name]      || @div_name, 
               options[:base]          || "/", 
               options[:swf_file_name] || "open-flash-chart.swf", 
               options[:width]         || 550, 
               options[:height]        || 300, 
               options[:protocol]      || @protocol, 
               options[:obj_id]        || @obj_id)
    end

    def get_object_values(url)
      @ofc_url      = CGI::escape(url)
      # need something that will not be repeated on the same request
      @special_hash = Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}/#{@ofc_url}"))[0..7]
      # only good characters for our div
      @special_hash = @special_hash.gsub(/[^a-zA-Z0-9]/,rand(10).to_s)
      @obj_id   = "chart_#{@special_hash}"  # some sequencing without all the work of tracking it
      @div_name = "flash_content_#{@special_hash}"
      @protocol = "http" # !request.nil? ? request.env["HTTPS"] || "http" : "http"
    end

    def get_html(url, div_name, base, swf_file_name, width, height, protocol, obj_id)
      # NOTE: users should put this in the <head> section themselves:
      ## <script type="text/javascript" src="#{base}/javascripts/swfobject.js"></script>

      <<-HTML
      <div id="#{div_name}"></div>
      <script type="text/javascript">
        swfobject.embedSWF("#{base}#{swf_file_name}", "#{div_name}", "#{width}", "#{height}", "9.0.0", "expressInstall.swf",{"data-file":"#{url}"});
      </script>
      HTML
    end
  end

end
