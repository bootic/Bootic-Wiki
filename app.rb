# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require "redcarpet"
require "dragonfly"
require "multi_json"

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'page'
require 'helpers'

class App < Sinatra::Base

  set :public_folder, File.dirname(__FILE__) + '/public'
  set :root, File.dirname(__FILE__)
  disable :protection # allow jsonp

  helpers do
    include Helpers
  end

  configure do
    Page.load(settings.root + '/views', ['404.mkd'])
    ::IMAGES = Dragonfly[:images].configure_with(:imagemagick).configure do |c|
      c.url_path_prefix = '/i'
      c.protect_from_dos_attacks = true
      c.secret = ENV['DRAGONFLY_SECRET'] || 'f00barsupers3cr3t'
    end
    IMAGES.datastore.configure do |d|
      d.root_path = settings.public_folder
    end
  end

  before do
    cache_long
  end

  get '/sitemap.xml' do
    builder :sitemap
  end

  get '/robots.txt' do
    content_type 'text/plain'
    erb :robots, :layout => false
  end

  get '/index.json' do
    content_type 'application/json'
    MultiJson.encode Page.flat_list(url(''))
  end

  # resizable images with Dragonfly
  get '/i/:path' do |path|
    Dragonfly::Job.from_path(path, IMAGES).validate_sha!(params[:s]).to_response(env)
  end

  get '/?' do
    load_page ''
  end

  get '/*.json' do
    if page = Page.find('/'+params[:splat].first)
      content_type 'application/json'
      data = page.serializable_hash(url(''))
      data[:body] = coderay(render_markup(page.body))
      MultiJson.encode data
    else
      render_404
    end
  end

  get '/cheatsheet' do
    redirect '/cheatsheet/index.html'
  end

  get '/*' do
    load_page params[:splat].first
  end

end
