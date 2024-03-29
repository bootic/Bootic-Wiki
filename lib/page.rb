class Page

  class << self

    def pages
      (@pages ||= {})
    end

    def slugs
      (@slugs ||= {})
    end

    def groups
      (@groups ||= {})
    end

    def add(page)
      pages[page.url] = page
      slugs[page.slug] = page
      if group = page.info[:group]
        (groups[group[:name]] ||= []) << page
      end
      page
    end

    def find(url)
      pages[url]
    end

    def find_by_slug(slug)
      slugs[slug]
    end

    def root
      @root ||= []
    end

    def flat_list(host = '')
      @flat_list = (
        host.gsub!(/\/$/, '')
        list = []
        root.each do |page|
          populate_recursive list, page, host
        end
        list
      )
    end

    def populate_recursive(list, page, host = '', depth = 1)
      list << page.serializable_hash(host, depth)
      page.each do |child|
        populate_recursive list, child, host, depth+1
      end if page.size > 0
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

  attr_reader :path, :title, :description, :body, :keywords, :position, :url, :sitemap_priority, :info

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

  def slug
    @url.split('/').last
  end

  def content
    if body.strip.blank?
      "# #{title}\n\n#{intro}" + @children.sort.collect do |c|
      # "# #{title}\n\n" + @children.sort.collect do |c|
        "### [#{c.title}](#{c.url})\n\n#{c.description}"
      end.join("\n\n")
    else
      body
    end
  end

  def intro
    # @intro.present? ? "#{@intro}\n\n" : ""
    ""
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

  def serializable_hash(host = '', depth = 1)
    @serializable_hash ||= (
      hash = [:title, :description, :keywords, :position, :url, :headings].inject({}) do |mem, key|
        mem[key] = send(key)
        mem
      end
      hash[:href] = host + url
      hash[:depth] = depth
      hash
    )
  end

  def headings
    @headings ||= body.scan(/#+\s*(.+)/).flatten.map { |e| e.gsub(/<\/?[^>]*>/, "")}
  end

  def in_menus?
    @info[:in_menus] != false
  end

  def group_label
    @group_label ||= (info[:group] && info[:group][:label]) ? info[:group][:label] : title
  end

  protected

  def load_info
    @body = File.read(@path).to_s
    @body =~ EXPR
    content = $1
    if content
      @info = YAML.load(content)
      @title = @info[:title]
      @description = @info[:description] || "Artículo sobre #{@title}"
      @body.gsub!(EXPR, '')
      @keywords = @info[:keywords]
      @sitemap_priority = @info[:sitemap_priority]
      @intro = @info[:intro]
    else
      @info = {}
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
