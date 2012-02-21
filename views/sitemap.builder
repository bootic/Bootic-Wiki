# products 0.9
# collections 0.8
# posts 0.7
# pages, forms 0.5

xml.instruct!

xml.urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do

    xml.url do
        xml.loc "http://#{request.host}/"
        xml.lastmod Time.now.strftime("%Y-%m-%dT%H:%M:%S+00:00")
        xml.changefreq "always"
    end

    menu.each do |page|
      recursive_xml xml, page
    end

end