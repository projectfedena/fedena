module OpenFlashChart

  class PieValue < Base
    def initialize(value, label, args={})
      super args
      @value = value
      @label = label      
    end

    def set_label(label, label_color, font_size)
      self.label        = label
      self.label_colour = label_color
      self.font_size    = font_size
    end

    def on_click(event)
      @on_click = event
    end
  end

  class Pie < Base
    def initialize args={}
      @type = "pie"
      @colours = ["#d01f3c","#356aa0","#C79810"]
      @border = 2
      super
    end

    def set_no_labels
      self.no_labels = true
    end

    def on_click(event)
      @on_click = event
    end
  end

end