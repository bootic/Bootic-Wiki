require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require "rdiscount"

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'menu'
require 'page'
require 'helpers'

class App < Sinatra::Base
  
  set :public, File.dirname(__FILE__) + '/public'
  set :root, File.dirname(__FILE__)
  #set :markdown, :layout => true
  
  helpers do
    include Helpers
  end
  
  before do
    cache_long
  end
  
  get '/?' do
    mkd 'index'
  end
  
  get '/:lang' do
    mkd params[:lang]
  end
  
  get '/:lang/*' do
    mkd File.join(params[:lang], params[:splat].first)
  end
end