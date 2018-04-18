class Redirects
  def self.redirect_to(path, code)
    [code, {'Content-Type' => 'text/html', 'Location' => path}, ['<h1>Redirecting...</h1>']]
  end

  def initialize(app, opts = {})
    @app = app
    @static_urls = opts[:static] || {}
    @regexes     = opts[:regex] || {}
    @code        = opts[:code] || 301
  end

  def call(env)
    if new_url = @static_urls[env['PATH_INFO']] || match_regex(env['PATH_INFO'])
      return self.class.redirect_to(new_url, @code)
    else
      @app.call env
    end
  end

  def match_regex(from)
    @regexes.each do |regex, to|
      return to if regex =~ from
    end
    nil
  end
end