# encoding: UTF-8
$:.unshift File.expand_path(File.dirname(__FILE__))
require 'app'
require 'coderay'
require 'rack/contrib'

require File.dirname(__FILE__) + '/lib/code_highlighter'
require File.dirname(__FILE__) + '/lib/redirects'

use Redirects, {
  static: {
    '/es/configuracion/formas-de-envio' => '/es/configuracion/opciones-de-envio'
  },
  regex: {
    /^\/es\/diseno\/(.*)/ => '/es/diseno'
  }
}

use Codehighlighter
use Rack::JSONP
run App
