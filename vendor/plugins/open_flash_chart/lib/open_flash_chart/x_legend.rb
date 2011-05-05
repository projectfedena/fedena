module OpenFlashChart

  class XLegend < Base
    def initialize(text, args={})
      super args
      @text = text      
    end
  end

end