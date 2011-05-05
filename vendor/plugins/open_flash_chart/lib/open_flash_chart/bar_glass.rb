module OpenFlashChart

  class BarGlass < BarBase
    def initialize args={}
      super
      @type = "bar_glass"      
    end
  end

  class BarGlassValue < Base
    def initialize(top, args={})
      @top = top
      super args
    end
  end

end