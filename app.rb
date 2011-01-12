require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require "rdiscount"

class Page
  
  include Enumerable
  
  attr_reader :path, :name
  
  def initialize(path)
    @path = path
    @children = []
    process!
  end
  
  def <<(child)
    @children << child
  end
  
  def each(&block)
    @children.each &block
  end
  
  def size
    @children.size
  end
  
  def subdir
    @subdir ||= @path.sub(File.extname(@path), '')
  end
  
  def has_subdir?
    File.directory? subdir
  end
  
  def url
    @url ||= @path.split('views').last.sub(File.extname(@path), '')
  end
  
  protected
  
  def process!
    @name = File.basename(@path, File.extname(@path))
  end
end

class Menu
  
  attr_reader :root
  
  def initialize(path, except = [])
    @path, @except = path, except
    @root = []
    build! @root, @path
  end
  
  def each(&block)
    @root.each &block
  end
  
  protected
  
  def build!(level, path)
    Dir[path + '/*.mkd'].each do |p|
      next if @except.include?(File.basename(p))
      page = Page.new(p)
      level << page
      if page.has_subdir?
        build!(page, page.subdir)
      end
    end
  end
  
end

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
    
    def partial(page, options={})
      erb :"_#{page}", options.merge!(:layout => false)
    end
    
    def menu
      @menu ||= Menu.new(options.root + '/views/' + params[:lang], ['404.mkd']) if params[:lang]
    end
    
    def build_menu(page)
      klass = 'current' if page.url == '/'+@current_path
      str = %(<li class="page">)
      str << %(<a href="#{page.url}" class="#{klass}">#{page.name}</a>)
      if page.size > 0
        page.each do |child|
          str << %(<ul>)
          str << build_menu(child)
          str << %(</ul>)
        end
      end
      str << %(</li>)
    end
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