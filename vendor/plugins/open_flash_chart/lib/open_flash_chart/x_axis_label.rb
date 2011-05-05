module OpenFlashChart

  class XAxisLabel < Base
    def initialize(text, colour, size, rotate, args={})
      super args
      @text   = text
      @colour = colour
      @size   = size
      @rotate = rotate      
    end

    def set_vertical
      @rotate = "vertical"
    end

    def set_visible
      @visible = true
    end
  end

end