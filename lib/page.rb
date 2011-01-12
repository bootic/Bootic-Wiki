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