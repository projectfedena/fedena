begin
  require "rubygems"
  gem 'i18n', "~> 0.4.0"
rescue LoadError
  puts 'Fedena requires i18n gem version 0.4.0 to be installed.Run gem install i18n -v 0.4.0'
end