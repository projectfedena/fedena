module OpenFlashChart

  class LineDot < LineBase
    def initialize args={}
      super
      @type = "line_dot"
    end
  end

  class DotValue < Base
    def initialize(value, colour, args={})
      @value = value
      @colour = colour
      super(args)
    end
  end
end
