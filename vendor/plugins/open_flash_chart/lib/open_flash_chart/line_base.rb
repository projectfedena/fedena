module OpenFlashChart

  class LineBase < Base
    def initialize args={}
      super
      @type = "line_dot"
      @text = "Page Views"
      @font_size = 10
      @values = [9,6,7,9,5,7,6,9,7]      
    end

    def loop
      @loop = true
    end
  end

end