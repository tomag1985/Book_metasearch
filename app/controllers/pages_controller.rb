require 'open-uri'
require 'nokogiri'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :about ]

  def home
    @books = Book.name
    @suggestions = suggestions  
  end

  def about
  end

  def wishlist
    @books = Book.where(user: current_user)
  end


  private

  def search_yenny
    begin
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
    rescue
      nil
    end
  end

  def search_cuspide
    url = "https://www.cuspide.com/"
    begin
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
    rescue
      nil
    end
  end

  def search_hernandez
    url = "https://www.libreriahernandez.com/recomendados/"
    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)
      
      covers = doc.css("#content .bookset ul")
      covers_img = []
      urls = []
      hash = {}
    
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
    rescue
      nil
    end
  end

  def search_bookdep
    url = "https://www.bookdepository.com/"
    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)

      covers_img = []
      urls = []
      hash = {}

      i = 1

      while i < 8
        covers_img << doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.no-borders.home-page > div:nth-child(6) > div.block > div > div > div > div:nth-child(#{i}) > div.item-img > a > img")["data-lazy"]
        i += 1
      end

      i = 1

      while i < 8
        href = doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.no-borders.home-page > div:nth-child(6) > div.block > div > div > div > div:nth-child(#{i}) > div.item-img > a")["href"]
        url = "https://www.bookdepository.com/#{href}?ref=grid-view"
        urls << url
        i += 1
      end

      i = 0
      covers_img.each do |cover|
        hash[cover] = urls[i]
        i += 1
      end
      hash
    rescue
      nil
    end
  end

  def search_meli
    url = "https://libros.mercadolibre.com.ar/libros/"
    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)

      covers_img = []
      urls = []
      hash = {}

      i = 1

      while i < 8
        covers_img << doc.at_css("#root-app > div > div.ui-search-main.ui-search-main--exhibitor.ui-search-main--only-products > section > ol > li:nth-child(#{i}) > div > div > div.ui-search-result__image > a > div > div > div > div > div > img")["data-src"]
        i += 1
      end

      i = 1

      while i < 8
        url = doc.at_css("#root-app > div > div.ui-search-main.ui-search-main--exhibitor.ui-search-main--only-products > section > ol > li:nth-child(#{i}) > div > div > div.ui-search-result__image > a")["href"]
        urls << url
        i += 1
      end

      i = 0
      covers_img.each do |cover|
        hash[cover] = urls[i]
        i += 1
      end
      hash
    rescue
      nil
    end
  end

  def suggestions
    yenny = search_yenny
    cuspide = search_cuspide
    hernandez = search_hernandez
    bookdep = search_bookdep
    meli = search_meli
    books = {}
    books[:yenny] = yenny
    books[:cuspide] = cuspide
    books[:hernandez] = hernandez
    books[:bookdep] = bookdep
    books[:meli] = meli
    books
  end
end
