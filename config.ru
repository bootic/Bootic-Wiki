# encoding: UTF-8
$:.unshift File.expand_path(File.dirname(__FILE__))
require 'app'
require 'coderay'
require 'rack/contrib'

require File.dirname(__FILE__) + '/lib/code_highlighter'

class Redirects
  def initialize(app, from_exp:, to:, code: 301)
    @app = app
    @from_exp = from_exp
    @to = to
    @code = code
  end

  def call(env)
    if env['PATH_INFO'] =~ @from_exp
      uri = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{@to}"
      [@code, {'Content-Type' => 'text/html', 'Location' => uri}, ["redirecting"]]
    else
      @app.call env
    end
  end
end

use Redirects, from_exp: /^\/es\/diseno\/?/, to: '/diseno', code: 301
use Codehighlighter
use Rack::JSONP

run App
