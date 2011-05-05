module OpenFlashChart

  class BarSketch < BarBase
    def initialize(colour, outline_colour, fun_factor, args = {} )
      super args
      @type           = "bar_sketch"
      @colour         = colour
      @outline_colour = outline_colour
      @offset         = fun_factor      
    end
  end

end