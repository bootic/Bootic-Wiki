require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require "rdiscount"

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'page'
require 'helpers'

class App < Sinatra::Base
  
  set :public, File.dirname(__FILE__) + '/public'
  set :root, File.dirname(__FILE__)
  
  helpers do
    include Helpers
  end
  
  configure do
    Page.load(options.root + '/views', ['404.mkd'])
  end
  
  before do
    cache_long
  end
  
  get '/?' do
    load_page 'index'
  end
  
  get '/:lang' do
    load_page params[:lang]
  end
  
  get '/:lang/*' do
    load_page File.join(params[:lang], params[:splat].first)
  end
end