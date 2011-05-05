module OpenFlashChart

  class Line < LineBase
    def initialize args={}
      super
      @type = "line"      
    end
  end

end