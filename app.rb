require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require "rdiscount"

class App < Sinatra::Base
  
  set :public, File.dirname(__FILE__) + '/public'
  set :root, File.dirname(__FILE__)
  #set :markdown, :layout => true
  
  helpers do
    def cache_long(seconds = 3600)
      response['Cache-Control'] = "public, max-age=#{seconds.to_i}"
    end
    
    def mkd(page)
      @content = RDiscount.new(File.read(File.join(options.root, 'views', "#{page}.mkd"))).to_html
      erb :layout
    end
  end
  
  before do
    cache_long
  end
  
  get '/?' do
    mkd 'index'
  end
  
  get '/*' do
    mkd params[:splat].first
  end
end