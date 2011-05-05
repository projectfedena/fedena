require 'action_pack/version'

# This class exists so including the Rails HTML sanitization helpers doesn't pollute your models.
class RailsSanitize
  if ActionPack::VERSION::MINOR >= 2 # Rails 2.2+
    extend ActionView::Helpers::SanitizeHelper::ClassMethods
  else # Rails 2.1 or earlier (note: xss_terminate does not support Rails 1.x)
    include ActionView::Helpers::SanitizeHelper
  end
end
