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
      @current_path = page
      path = File.join(options.root, 'views', "#{page}.mkd")
      if !File.exists?(path)
        @content = RDiscount.new(File.read(File.join(options.root, 'views', '404.mkd'))).to_html
        halt 404, erb(:layout)
      else
        root_segment = page.split('/').first # themes, docs, etc.
        menu_name = File.join(options.root, 'views', root_segment, 'menu.erb')
        @sub_menu = File.exists?(menu_name) ? File.join(root_segment, 'menu') : nil
        @content = RDiscount.new(File.read(path)).to_html
        erb :layout
      end
    end
    
    def sub_menu
      erb @sub_menu.to_sym if @sub_menu
    end
    
    def menu_item(name, path)
      klass = 'current' if path == '/'+@current_path
      %(<a href="#{path}" class="#{klass}">#{name}</a>)
    end
    
    def partial(page, options={})
      erb :"_#{page}", options.merge!(:layout => false)
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