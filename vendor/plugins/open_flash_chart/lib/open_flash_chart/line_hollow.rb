module OpenFlashChart

  class LineHollow < LineBase
    def initialize args={}
      super
      @type = "line_hollow"
    end
  end

end