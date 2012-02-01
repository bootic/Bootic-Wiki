# encoding utf-8
$:.unshift File.expand_path(File.dirname(__FILE__))
require 'app'
require 'coderay'  

require File.dirname(__FILE__) + '/lib/code_highlighter'
use Codehighlighter

run App