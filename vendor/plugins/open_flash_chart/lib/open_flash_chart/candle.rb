module OpenFlashChart

  class Candle < Base
    def initialize(args={})
      super args
      @type = "candle"   
    end
  end
  
  class CandleValue < Base
    def initialize( top, bottom, low, high, args={} )
      @top = top
      @bottom = bottom
      @low = low
      @high = high
      super args
    end
  end

end