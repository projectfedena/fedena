module ApplicationHelper
  def get_stylesheets
    stylesheets = [] unless stylesheets
    ["#{controller.controller_path}/#{controller.action_name}"].each do |ss|
      stylesheets << ss
    end
  end

  def observe_fields(fields, options)
	  with = ""                          #prepare a value of the :with parameter
	  for field in fields
		  with += "'"
		  with += "&" if field != fields.first
		  with += field + "='+escape($('" + field + "').value)"
		  with += " + " if field != fields.last
	  end

	  ret = "";      #generate a call of the observer_field helper for each field
	  for field in fields
		  ret += observe_field(field,	options.merge( { :with => with }))
	  end
	  ret
  end

  def shorten_string(string, count)
    if string.length >= count
      shortened = string[0, count]
      splitted = shortened.split(/\s/)
      words = splitted.length
      splitted[0, words-1].join(" ") + ' ...'
    else
      string
    end
  end

  def currency
    Configuration.find_by_config_key("CurrencyType").config_value
  end

  def pdf_image_tag(image, options = {})
  options[:src] = File.expand_path(RAILS_ROOT) + "/public/images"+ image
  tag(:img, options)
end
  
end
