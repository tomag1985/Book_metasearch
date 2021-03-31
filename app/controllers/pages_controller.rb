require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @books = Book.name
    @suggestions = suggestions
    
  end


  def search_yenny
    url = "https://www.tematika.com/"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)
    library = "Yenny"
    covers = doc.css(".jm-product-list .products-grid .product-image img")
    covers = covers[4..10]
    urls = doc.css(".products-grid li.item .product-image a")
    urls = urls[0..12]
    hash = {}
    i = 0
    covers.each do |cover|
      hash[cover] = urls[i]
      i += 2
    end
    hash
  end


  def suggestions
    yenny = search_yenny
    #cuspide = search_cuspide(title)
    books = {}
    #books[:cuspide] = cuspide
    books[:yenny] = yenny
    books
  end
end
