# encoding: utf-8
require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require "rdiscount"
require "dragonfly"

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
    ::IMAGES = Dragonfly[:images].configure_with(:imagemagick).configure do |c|
      c.url_path_prefix = '/i'
      c.protect_from_dos_attacks = true
      c.secret = ENV['DRAGONFLY_SECRET'] || 'f00barsupers3cr3t'
    end
    IMAGES.datastore.configure do |d|
      d.root_path = options.public
    end
  end
  
  before do
    cache_long
  end
  
  # resizable images with Dragonfly
  get '/i/:path' do |path|
    Dragonfly::Job.from_path(path, IMAGES).validate_sha!(params[:s]).to_response(env)
  end
  
  get '/?' do
    load_page ''
  end
  
  get '/*' do
    load_page params[:splat].first
  end
  
end