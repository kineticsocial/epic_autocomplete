# Install hook code here
require 'fileutils'

puts "COPYING: public/javascripts/jquery.autocomplete.js to your public folder"
cp "#{File.dirname(__FILE__)}/public/javascripts/jquery.autocomplete.js", "#{RAILS_ROOT}/public/javascripts/jquery.autocomplete.js" 
puts "COPYING: public/stylesheets/jquery.autocomplete.css to your public folder"
cp "#{File.dirname(__FILE__)}/public/stylesheets/jquery.autocomplete.css", "#{RAILS_ROOT}/public/stylesheets/jquery.autocomplete.css" 