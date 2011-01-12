module Helpers
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