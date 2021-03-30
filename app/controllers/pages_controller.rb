require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @books = Book.name
    suggestions
  end


  def search_yenny
    url = "https://www.tematika.com/"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)
    library = "Yenny"
    raise
    #Book.new(title: title, description: book[:description], rating: book[:rating], library: library, price: price)
  end


  def suggestions
    yenny = search_yenny
    cuspide = search_cuspide(title)
    books = {}
    books[:cuspide] = cuspide
    books[:yenny] = yenny
    books
  end
end
