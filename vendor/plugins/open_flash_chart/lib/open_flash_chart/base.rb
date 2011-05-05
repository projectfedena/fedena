module OpenFlashChart
  class Base

    def initialize(args={})
      # set all the instance variables we want
      # assuming something like this OpenFlashChart.new(:x_axis => 5, :y_axis => 10, :elements => ["one", "two"], ...)
      args.each do |k,v|
        self.instance_variable_set("@#{k}", v)
      end
      yield self if block_given?  # magic pen pattern
    end

    # same as to_s but won't stack overflow ... use this instead of to_s
    def render
      # need to return the following like this
      # 1) font_size as font-size 
      # 2) dot_size as dot-size
      # 3) outline_colour as outline-colour
      # 4) halo_size as halo-size
      # 5) start_angle as start-angle
      # 6) tick_height as tick-height
      # 7) grid_colour as grid-colour
      # 8) threed as 3d
      # 9) tick_length as tick-length
      # 10) visible_steps as visible-steps
      # 11) key_on_click as key-on-click
      returning self.to_json2 do |output|
        output.gsub!("threed","3d")
        %w(font_size dot_size outline_colour halo_size start_angle tick_height grid_colour tick_length no_labels label_colour gradient_fill fill_alpha on_click spoke_labels visible_steps key_on_click).each do |replace|
          output.gsub!(replace, replace.gsub("_", "-"))
        end
      end
    end

    def to_json2
      self.instance_values.to_json
    end    

    alias_method :to_s, :render

    def add_element(element)
      @elements ||= []
      @elements << element
    end

    def <<(e)
      add_element e
    end

    def set_key(text, size)
      @text      = text
      @font_size = size
    end

    def append_value(v)
      @values ||= []
      @values << v
    end

    def set_range(min,max,steps=1)
      @min   = min
      @max   = max
      @steps = steps
    end

    def set_offset(v)
      @offset = v ? true : false
    end

    def set_colours(colour, grid_colour)
      @colour      = colour
      @grid_colour = grid_colour
    end

    def set_tooltip(tip)
      if tip.is_a?(Tooltip)
        #we have a style for our chart's tooltips
        @tooltip = tip
      else
        # the user could just use set_tip(tip) or tip=(tip) to just set the text of the tooltip
        @tip = tip
      end
    end
    alias_method "tooltip=", :set_tooltip



    def method_missing(method_name, *args, &blk)
      case method_name.to_s
      when /(.*)=/   # i.e., if it is something x_legend=
        # if the user wants to set an instance variable then let them
        # the other args (args[0]) are ignored since it is a set method
        self.instance_variable_set("@#{$1}", args[0])
      when /^set_(.*)/
        # backwards compatible ... the user can still use the same set_y_legend methods if they want
        self.instance_variable_set("@#{$1}", args[0])
      else
        # if the method/attribute is missing and it is not a set method then hmmmm better let the user know
        super
      end
    end

  end
end
