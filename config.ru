require 'app'
require 'coderay'  
# require 'rack/codehighlighter'

# use Rack::Codehighlighter, :coderay, :element => "pre", :pattern => /\A:::(\w+)\s*\n/, :line_numbers => true, :logging => true

require File.dirname(__FILE__) + '/lib/code_highlighter'
use Codehighlighter

run App