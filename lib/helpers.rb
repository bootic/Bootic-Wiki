module Helpers

  def web_host
    'https://www.bootic.io'
  end

  # returns true if we're showing a language index (/es or /en)
  def is_index?
    request.path[/^\/([^\/]+)$/]
  end

  def cache_long(seconds = 3600)
    response['Cache-Control'] = "public, max-age=#{seconds.to_i}"
  end

  def mkd(page)
    @content = render_markup(page.content)
    return (pjax? or ajax?) ? @content : erb(:layout)
  end

  def markdown_engine
    @markdown_engine ||= begin
      renderer = Redcarpet::Render::HTML.new(:with_toc_data => true)
      engine = Redcarpet::Markdown.new(renderer,
        :autolink => true,
        :space_after_headers => true,
        :no_intra_emphasis => true
      )
      engine
    end
  end

  def render_markup(markup)
    erb_content = ERB.new(markup).result(binding)
    markdown_engine.render(erb_content)
  end

  def coderay(body)
    body.gsub!(/<pre>:::(\w+)?\s(.+?)?<\/pre>/im) do |match|
      "<pre class='CodeRay'>#{::CodeRay.encoder(:html).encode($2, $1)}</pre>"
    end
  end

  def render_404
    @content = render_markup(File.read(File.join(settings.root, 'views', '404.mkd')))
    halt 404, erb(:layout)
  end

  def partial(page, options={})
    erb :"_#{page}", options.merge!(layout: false)
  end

  def menu(path = '/')
    @menu ||= if path == '/'
      Page.root
    else
      Page.find(path)
    end
  end

  def page_class
    return 'not_found' unless @page
    @page.url.split('/').reject { |e| e == '' }.join('_')
  end

  # section to build menu from.
  # ie. for URL /es/administration/foo/bar section is "/es/administration"
  #
  def menu_section
    @menu_section ||= begin
      s = request.path.split('/')
      s[0..2].join('/')
    end
  end

  # Load a menu for the current seciton of the wiki
  #
  def current_section
    @current_section ||= menu(menu_section)
  end

  def pjax?
    !!request.env['HTTP_X_PJAX']
  end

  def ajax?
    request.xhr?
  end

  def load_page(url, json = false)
    if @page = Page.find('/' + url)
      mkd @page
    elsif @page = Page.find_by_slug(url.split('/').last)
      redirect to(@page.url), 301
    else
      render_404
    end
  end

  def recursive_xml(xml, page, level = 1.0)
    xml.url do
      xml.loc url(page.url)
      xml.changefreq "weekly"
      xml.priority(page.sitemap_priority || level)
    end

    page.each do |child|
      recursive_xml xml, child, level/2
    end if page.size > 0
  end

  def build_menu(page, depth = 1)
    return '' unless page.in_menus?
    klass = match_path(page)
    str = %(<li class="page page-#{page.slug} #{klass} depth_#{depth}">)
    str << %(<a href="#{page.url}" title="#{page.description}">#{page.title}</a>)
    if page.size > 0
      page.each_with_index do |child, i|
        str << %(<ul class="depth_#{depth+1} number_#{i}">)
        str << build_menu(child, depth + 1)
        str << %(</ul>)
      end
    end
    str << %(</li>)
  end

  def match_path(page)
    return "none" unless @page
    if @page.url == page.url
      "current"
    elsif @page.url[page.url]
      "in_path"
    else
      ""
    end
  end

  def current_url
    return '' unless @page
    schema = development? ? 'http' : 'https'
    "#{schema}://#{request.env['HTTP_HOST']}#{@page.url}"
  end

  def development?
    ENV['RACK_ENV'] == 'development'
  end

  def img(path, size = nil)
    ::IMAGES.fetch(path.sub(/^\//, ''))
  end

end
