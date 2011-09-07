class Platform

 def self.is_windows?
  RUBY_PLATFORM =~ /mswin|mingw|bccwin|wince/i
 end

 def self.is_linux?
  RUBY_PLATFORM =~ /linux|netbsd|cygwin/i
 end
end