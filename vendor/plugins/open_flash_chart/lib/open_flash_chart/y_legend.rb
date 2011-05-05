module OpenFlashChart

  class YLegend < Base
    def initialize(text = '', args={})
      super args
      @text = text      
    end
  end

end