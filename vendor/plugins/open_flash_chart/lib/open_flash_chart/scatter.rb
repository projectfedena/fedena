module OpenFlashChart

  class ScatterValue < Base
    def initialize(x,y,dot_size=nil, args={})
      super args
      @x = x
      @y = y
      @dot_size = dot_size if dot_size.to_i > 0      
    end
  end

  class Scatter < Base
    def initialize(colour, dot_size, args={})
      @type = "scatter"
      @colour = colour
      @dot_size = dot_size
      super args
    end
  end

end