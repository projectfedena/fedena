module OpenFlashChart

  class RadarSpokeLabels < Base
    def initialize(labels, args={})
      super args
      @labels = labels      
    end
  end

end