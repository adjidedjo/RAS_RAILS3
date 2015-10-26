module UrlHelper
  def url_with_protocol
    url = "192.168.101.220:1107/search_sales/new"
    /^http/i.match(url) ? url : "http://#{url}"
  end
end