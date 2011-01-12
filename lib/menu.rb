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