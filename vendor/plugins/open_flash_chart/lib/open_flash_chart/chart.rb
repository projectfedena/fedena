module OpenFlashChart

  class Chart < Base
    def initialize( title=nil, args={})
      super args
      @title = Title.new( title ) if title      
    end    
  end

  class OpenFlashChart < Chart
  end

end
