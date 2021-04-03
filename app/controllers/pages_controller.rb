require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @books = Book.name
    @suggestions = suggestions
    
  end


  private

  def search_yenny
    url = "https://www.tematika.com/"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)
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

  def search_cuspide
    url = "https://www.cuspide.com/"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)

    covers = doc.css("section.cien article")
    covers_img = []
    urls = []
    hash = {}

    i = 0
    covers.each do |cover|
      if i < 7
        covers_img << cover.at_xpath("//*[@id='ctl00_ContentPlaceHolder1_top100_rptMasVendidos_ctl0#{i}_img_tapa']")["data-original"]
        i += 1
      end
    end

    i = 0
    url =  "https://www.cuspide.com/"
    covers.each do |cover|
      if i < 7
        cover = cover.at_xpath("//*[@id='ctl00_ContentPlaceHolder1_top100_rptMasVendidos_ctl0#{i}_a_tapa_libro']")["href"]
        urls << url + cover
        i += 1
      end
    end

    i = 0
    covers_img.each do |cover|
      hash[cover] = urls[i]
      i += 1
    end
    hash
  end

  def search_hernandez
    url = "https://www.libreriahernandez.com/recomendados/"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)

    covers = doc.css("#content .bookset ul")
    covers_img = []
    urls = []
    hash = {}
    test = []
  
    i = 1
    url = "http:"
    covers.each do |cover|
      cover = cover.at_xpath("//*[@id='content']/div[3]/ul[#{i}]/li[1]/div[1]/a/img")["src"]
      covers_img << url + cover
      i += 1
    end

    i = 1
    url = "https://www.libreriahernandez.com/"
    covers.each do |cover|
      cover = cover.at_xpath("//*[@id='content']/div[3]/ul[#{i}]/li[1]/div[1]/a")["href"]
      urls << url + cover
      i += 1
    end

    i = 0
    covers_img.each do |cover|
      hash[cover] = urls[i]
      i += 1
    end
    hash
  end



  def suggestions
    yenny = search_yenny
    cuspide = search_cuspide
    hernandez = search_hernandez
    books = {}
    books[:yenny] = yenny
    books[:cuspide] = cuspide
    books[:hernandez] = hernandez
    books
  end
end
