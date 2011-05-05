module OpenFlashChart
  module View
    def periodically_call_function(function, options = {})
      frequency = options[:frequency] || 10 # every ten seconds by default
      code = "new PeriodicalExecuter(function() {#{function}}, #{frequency})"
      ActionView::Base.new.javascript_tag(code)
    end

    def js_open_flash_chart_object(div_name, width, height, base="/")
      <<-OUTPUT
      <script type="text/javascript">
      swfobject.embedSWF("#{base}open-flash-chart.swf", "#{div_name}", "#{width}", "#{height}", "9.0.0");
      </script>
      #{self.to_open_flash_chart_data}
      <div id="#{div_name}"></div>
      OUTPUT
    end

    def link_to_ofc_load(link_text, div_name)
      data_name = "#{link_text.gsub(" ","_")}_#{div_name.gsub(" ","_")}"
      <<-OUTPUT
      <script type="text/javascript">
      function load_#{data_name}() {
      tmp_#{div_name} = findSWF("#{div_name}");
      x = tmp_#{div_name}.load(Object.toJSON(data_#{data_name}));
    }
    var data_#{data_name} = #{self.render};
    </script>
    #{ActionView::Base.new.link_to_function link_text, "load_#{data_name}()"}
    OUTPUT
  end

  def link_to_remote_ofc_load(link_text, div_name, url)
    fx_name = "#{link_text.gsub(" ","_")}_#{div_name.gsub(" ","_")}"
    <<-OUTPUT
    <script type="text/javascript">
    function reload_#{fx_name}() {
    tmp_#{div_name} = findSWF("#{div_name}");
    new Ajax.Request('#{url}', {
      method    : 'get',
      onSuccess : function(obj) {tmp_#{div_name}.load(obj.responseText);},
      onFailure : function(obj) {alert("Failed to request #{url}");}});
    }
    </script>
    #{ActionView::Base.new.link_to_function link_text, "reload_#{fx_name}()"}
    OUTPUT
  end

  def periodically_call_to_remote_ofc_load(div_name, url, options={})
    fx_name = "#{div_name.gsub(" ","_")}"
    # fix a bug in rails with url_for
    url = url.gsub("&amp;","&")
    <<-OUTPUT
    <script type="text/javascript">
    function reload_#{fx_name}() {
    tmp_#{div_name} = findSWF("#{div_name}");
    new Ajax.Request('#{url}', {
      method    : 'get',
      onSuccess : function(obj) {tmp_#{div_name}.load(obj.responseText);},
      onFailure : function(obj) {alert("Failed to request #{url}");}});
    }
    </script>
    #{periodically_call_function("reload_#{fx_name}()", options)}
    OUTPUT
  end


  def to_open_flash_chart_data
    # this builds the open_flash_chart_data js function
    <<-OUTPUT
    <script type="text/javascript">
    function ofc_ready() {
    }
    function open_flash_chart_data() {
      return Object.toJSON(data);
    }
    function findSWF(movieName) {
      if (navigator.appName.indexOf("Microsoft")!= -1) {
        return window[movieName];
        } else {
          return document[movieName];
        }
      }
      var data = #{self.render};
      </script>
      OUTPUT
    end
    
  end
end
