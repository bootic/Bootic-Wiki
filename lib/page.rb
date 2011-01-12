class Page
  
  
  class << self
    
    def pages
      (@pages ||= {})
    end
    
    def add(page)
      pages[page.url] = page
      page
    end
    
    def find(url)
      pages[url]
    end
    
    def root
      @root ||= []
    end

    def each(&block)
      root.each &block
    end

    def load(path, except = [])
      build! root, path, except
      root
    end
    
    def build!(level, path, except = [])
      Dir[path + '/*.mkd'].each do |p|
        next if except.include?(File.basename(p))
        page = Page.new(p)
        level << page
        if page.has_subdir?
          build!(page, page.subdir)
        end
      end
    end
  end
  
  include Enumerable
  
  attr_reader :path, :title, :description, :body
  
  EXPR = /---\s(.+)?\s---/m
  
  def initialize(path)
    @path = path
    @children = []
    process!
    Page.add(self)
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
    @body = File.read(@path).to_s
    @body =~ EXPR
    content = $1
    if content
      @info = YAML.load(content)
      @title = @info[:title]
      @description = @info[:description]
      @body.gsub!(EXPR, '')
    else
      @title = File.basename(@path, File.extname(@path))
    end
  end
end