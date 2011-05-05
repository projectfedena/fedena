module OpenFlashChart

  class HBarValue < Base
    def initialize(left,right=nil, args={})
      super args
      @left  = left
      @right = right || left      
    end
  end

  class HBar < Base
    def initialize(colour="#9933CC", args={})
      super args
      @type = "hbar"
      @colour = colour
      @values = []      
    end

    def set_values(v)
      v.each do |val|
        append_value(HBarValue.new(val))
      end
    end
  end

end