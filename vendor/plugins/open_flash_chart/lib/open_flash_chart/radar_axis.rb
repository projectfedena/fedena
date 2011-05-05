module OpenFlashChart

  class RadarAxis < Base
    def initialize(max, args={})
      super args
      @max = max      
    end
  end

end