require 'rack/utils'

class Codehighlighter
  include Rack::Utils
  
  def initialize(app, opts = {})
    @app = app
    @opts = {
      :element => "pre",
      :pattern => /\A:::([-_\w]+)\s*(\n|&#x000A;)/i,  # &#x000A; == line feed
      :reason => "[[--  ugly code removed  --]]", #8-)
      :markdown => false  
    }
    @opts.merge! opts
  end

  def call(env)
    began_at = Time.now
    status, headers, response = @app.call(env)
    headers = HeaderHash.new(headers)

    if !STATUS_WITH_NO_ENTITY_BODY.include?(status) &&
       !headers['transfer-encoding'] &&
        headers['content-type'] &&
        headers['content-type'].include?("text/html")

      body = ""
      response.each { |part| body += part }
      
      body.gsub!(/<pre>:::(\w+)?\s(.+?)?<\/pre>/im) do |match|
        "<pre class='CodeRay'>#{::CodeRay.encoder(:html).encode($2, $1)}</pre>"
      end

      headers['content-length'] = bytesize(body).to_s

      [status, headers, [body]]
    else
      [status, headers, response]  
    end
  end
  
end
