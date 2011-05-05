module OpenFlashChart

  class Title < Base
    def initialize(text='', args = {})
      super args
      @text = text      
    end
  end

end