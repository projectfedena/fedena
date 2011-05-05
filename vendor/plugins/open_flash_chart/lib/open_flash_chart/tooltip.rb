module OpenFlashChart

  class Tooltip < Base
    def set_body_style(style)
      @body = style
    end

    def set_title_style(style)
      @title = style
    end

    def set_background_colour(bg)
      @background = bg
    end

    def set_proximity
      @mouse = 1
    end

    def set_hover
      @mouse = 2
    end
  end

end