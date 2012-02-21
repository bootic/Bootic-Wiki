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
      root.select do |page|
        !page.draft?
      end.each &block
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
  
  attr_reader :path, :title, :description, :body, :keywords, :position, :url, :sitemap_priority
  
  EXPR = /---\s(.+)?\s---/m
  POSITION_EXPR = /^(\d+)?_.+/
  DRAFT_EXPR = /^draft-/
  
  def initialize(path)
    @path = path
    @children = []
    load_info
    parse_position_and_url
    Page.add(self)
  end
  
  def <<(child)
    @children << child
  end
  
  def each(&block)
    @children.select do |page|
      !page.draft?
    end.sort.each &block
  end
  
  def size
    @children.size
  end
  
  def subdir
    @subdir ||= File.join(File.dirname(@path), basename.sub(/^\d+_/, ''))
  end
  
  def basename
    @base ||= File.basename(@path).sub(File.extname(@path), '')
  end
  
  def draft?
    @draft ||= !!(basename =~ DRAFT_EXPR)
  end
  
  def has_subdir?
    File.directory? subdir
  end
  
  def <=>(other)
    position <=> other.position
  end
  
  protected
  
  def load_info
    @body = File.read(@path).to_s
    @body =~ EXPR
    content = $1
    if content
      @info = YAML.load(content)
      @title = @info[:title]
      @description = @info[:description]
      @body.gsub!(EXPR, '')
      @keywords = @info[:keywords]
      @sitemap_priority = @info[:sitemap_priority]
    else
      @title = File.basename(subdir)
    end
  end
  
  def parse_position_and_url
    basename =~ POSITION_EXPR
    if $1
      @position = $1.to_i
    else
      @position = 0
    end
    @url = subdir.split('views').last
    @url = '/' if @url == '/index'
  end
end