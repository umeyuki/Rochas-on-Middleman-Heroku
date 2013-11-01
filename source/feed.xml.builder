xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "Rochas"
  xml.id "http://rochas.cc/"
  xml.link "href" => "#{data.site.url}/"
  xml.link "href" => "#{data.site.url}/feed.xml", "rel" => "self"
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name "Rochas" }

  blog.articles[0..20].each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => "#{data.site.url}#{article.url}"
      xml.id "#{data.site.url}#{article.url}"
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name "Rochas" }
      xml.content article.body, "type" => "html"
    end
  end
end
