require 'json'
require 'rest-client'
require 'open-uri'
require 'nokogiri'

class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @books = search_online(params[:search_online])
  end
  
  def show
    @book = Book.find(params[:id])
  end
  
  def create
    @book = Book.find_or_created_by(params[:book])
    UserBook.create(book:@book, user: @current)
  end


  private

  def search_cuspide(search_term)
    url = "https://www.cuspide.com/resultados.aspx?c=#{search_term}&por=pal"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)
    library = "Cuspide"
    price = doc.search('//*[@id="ctl00_ContentPlaceHolder1_resultadosItems_rptResultadosMosaico_ctl00_article_container"]/div[2]/div[2]/div').text.strip
    title = doc.search('//*[@id="ctl00_ContentPlaceHolder1_resultadosItems_rptResultadosMosaico_ctl00_a_titulo"]').text.strip.split.map(&:capitalize).join(' ')
    author = doc.search('//*[@id="ctl00_ContentPlaceHolder1_resultadosItems_rptResultadosMosaico_ctl00_rptAutores_ctl00_a_autor"]').text.strip
    img_src = doc.search('//*[@id="ctl00_ContentPlaceHolder1_resultadosItems_rptResultadosMosaico_ctl00_img_tapa"]')[0]["src"]

    if price.empty? || title.empty? || author.empty?
      Book.new(title: "Book not found", description: "N/A", rating: "N/A", library: library, price: "N/A", img_src: "N/A")		
    else
      book = search_description_and_rating(title)
      Book.new(title: title, author: author, description: book[:description], rating: book[:rating], library: library, price: price, img_src: img_src)
    end
  end

  def search_hernandez(search_term)
    url = "https://www.bookdepository.com/es/search?searchTerm=#{search_term}&search=Find+book"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)
    library = "Hernandez"
    price = doc.search('/html/body/div[2]/div/div[2]/div[1]/div[2]/table/tbody/tr[2]/td[6]').text.strip
    title = doc.search('/html/body/div[2]/div/div[2]/div[1]/div[2]/table/tbody/tr[2]/td[2]/a/span').text.strip.split.map(&:capitalize).join(' ')
    author = doc.search('/html/body/div[2]/div/div[2]/div[1]/div[2]/table/tbody/tr[2]/td[1]/a/span').text.strip.split.map(&:capitalize).join(' ')
    
    first_url = doc.search('#tabla a')
    first_url = first_url[5]["href"]
    href = "https://www.libreriahernandez.com#{first_url}"
    html_content = open(href)
    doc = Nokogiri::HTML(html_content)
    path = doc.at_xpath("/html/body/div[2]/div/div[2]/div[1]/div[1]/div[1]/img")["src"]
    img_src = "https://#{path}"

    if price.empty? || title.empty? || author.empty?
      Book.new(title: "Book not found", description: "N/A", rating: "N/A", library: library, price: "N/A")
    else
      book = search_description_and_rating(title)
      Book.new(title: title, author: author, description: book[:description], rating: book[:rating], library: library, price: price, img_src: img_src)
    end	
  end

  def search_yenny(search_term)
    url = "https://www.tematika.com/catalogsearch/result/?q=#{search_term}"
    html_content = open(url)
    doc = Nokogiri::HTML(html_content)
    library = "Yenny"
    price = doc.search('/html/body/div/div[6]/div/div/div[1]/div/div/div[2]/ul/li[1]/div/div[2]/div[2]/span/span').text.strip
    title = doc.search('/html/body/div/div[6]/div/div/div[1]/div/div/div[2]/ul/li[1]/div/div[2]/h5/a').text.strip.split.map(&:capitalize).join(' ')
    author = doc.search('/html/body/div/div[6]/div/div/div[1]/div/div/div[2]/ul/li[1]/div/div[2]/div[1]').text.strip.split.map(&:capitalize).join(' ')

    if title != ""
      img = doc.search('.product-image img')
      img_src = img[4]["src"] 
    end
    
    if price.empty? || title.empty? || author.empty?
      Book.new(title:"Book not found", description: "N/A", rating: "N/A", library: library, price: "N/A", img_src:"N/A")		
    else
      book = search_description_and_rating(title)
      Book.new(title: title, author: author, description: book[:description], rating: book[:rating], library: library, price: price, img_src: img_src)
    end
  end

  def search_description_and_rating(title)
    url = "https://www.googleapis.com/books/v1/volumes?q=#{title}"
    response = RestClient.get url
    result = JSON.parse response.to_str
    book = {}
    rating = result['items'][0]['volumeInfo']['averageRating']
    description = result['items'][0]['volumeInfo']['description']
    book[:rating] = rating
    book[:description] = description
    book
  end

  def search_online(title)
    cuspide = search_cuspide(title)
    hernandez = search_hernandez(title)
    yenny = search_yenny(title)
    books = {}
    books[:cuspide] = cuspide
    books[:hernandez] = hernandez
    books[:yenny] = yenny
    books
  end
end
