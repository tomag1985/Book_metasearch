require 'json'
require 'rest-client'
require 'open-uri'
require 'nokogiri'
require 'webrick/httputils'

class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @books = search_online(params[:search_online])
    @book = Book.new
  end
  
  def show
    @book = Book.find(params[:id])
  end
  
  def create
    @book = Book.new(book_params)
    @book.user = current_user

    @book.save!

    redirect_to wishlist_path
  end


  private

  def book_params
    params.require(:book).permit(:title, :author, :library, :price, :img_src, :href, :description, :user)
  end

  def search_cuspide(search_term)
    url = "https://www.cuspide.com/resultados.aspx?c=#{search_term}&por=pal"
    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)
      library = "Cuspide"

      author = doc.search('//*[@id="ctl00_ContentPlaceHolder1_resultadosItems_rptResultadosMosaico_ctl00_rptAutores_ctl00_a_autor"]').text.strip

      if author != ""
        img_src = doc.search('//*[@id="ctl00_ContentPlaceHolder1_resultadosItems_rptResultadosMosaico_ctl00_img_tapa"]')[0]["src"]
        url = doc.at_css('#ctl00_ContentPlaceHolder1_resultadosItems_rptResultadosMosaico_ctl00_a_tapa_libro')["href"]
        href = "https://www.cuspide.com#{url}"
        
        html_content = open(href)
        doc = Nokogiri::HTML(html_content)
        
        price = doc.at_css("#ctl00_ContentPlaceHolder1_rptFicha_ctl00_precioContainer > div:nth-child(3)").inner_text

        if price != ""
          price[0..2] = ""
          price = price.gsub(".", "").strip!.to_i
        end

        title = doc.at_css("#ctl00_ContentPlaceHolder1_rptFicha_ctl00_a_titulo").inner_text
        description = doc.at_css("#ctl00_ContentPlaceHolder1_rptFicha_ctl00_itemPropDescription").inner_text.strip
    
      else
        img_src = "https://www.mobileread.com/forums/attachment.php?attachmentid=111264&d=1378642555"
      end
        
      if price.nil? || title.nil? || author.nil?
        nil		
      else
        # CREAR METODO CON ESTE ELSE Y LLAMARLO EN CADA UNO DE LOS METODOS DE LAS LIBRERIAS!!

        book = Book.find_or_initialize_by(title: title, author: author, library: library, img_src: img_src, href: href, description: description)
        
        book.price = price
        
        if book.persisted?
          book.save
        end

        book
      end
    rescue
      nil
    end
  end

  def search_hernandez(search_term)
    url = "https://www.libreriahernandez.com/busquedaRapida?perPage=14&sortBy=stockAndTitle&value=#{search_term}&image.x=0&image.y=0"
    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)
      library = "Hernandez"

      title = doc.search('/html/body/div[2]/div/div[2]/div[1]/div[2]/table/tbody/tr[2]/td[2]/a/span').text.strip.split.map(&:capitalize).join(' ')
      author = doc.search('/html/body/div[2]/div/div[2]/div[1]/div[2]/table/tbody/tr[2]/td[1]/a/span').text.strip.split.map(&:capitalize).join(' ')
      
      if author != ""
        first_url = doc.search('#tabla a')
        first_url = first_url[5]["href"]
        href = "https://www.libreriahernandez.com#{first_url}"
        html_content = open(href)
        doc = Nokogiri::HTML(html_content)
        
        price = doc.at_css("#ficha > div.ficha-datos > div.costo > p.libro-precio").inner_text
        if price != ""
          price[0] = ""
          price = price.strip.to_i
        end

        path = doc.at_xpath("/html/body/div[2]/div/div[2]/div[1]/div[1]/div[1]/img")["src"]
        img_src = "https://#{path}"
        description = "description not provided by library"
      else
        img_src = "https://www.mobileread.com/forums/attachment.php?attachmentid=111264&d=1378642555"
        description = "N/A"
      end

      if price.nil? || title.nil? || author.nil?
        nil
      else
        book = Book.find_or_initialize_by(title: title, author: author, library: library, img_src: img_src, href: href, description: description)
        
        book.price = price
        
        if book.persisted?
          book.save
        end

        book
      end	
    rescue
      nil
    end
  end

  def search_yenny(search_term)
    url = "https://www.tematika.com/catalogsearch/result/?q=#{search_term}"
    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)
      library = "Yenny"
      
      author = doc.search('/html/body/div/div[6]/div/div/div[1]/div/div/div[2]/ul/li[1]/div/div[2]/div[1]').text.strip.split.map(&:capitalize).join(' ')

      if author != ""
        href = doc.at_css('#jm-current-content > div.category-products > ul > li > div > div.product-image > a')["href"]
        
        html_content = open(href)
        doc = Nokogiri::HTML(html_content)

        
        price = doc.at_css("#product-price-138856 > span").inner_text.strip

        if price != ""
          price[0] = ""
          price = price.gsub(".", "").strip.to_i
        end
    
        title = doc.at_css("#product_addtocart_form > div.product-essential-inner > div.product-shop > div.product-name > h1").inner_text
        description = doc.at_css("#ja-tabitem-desc").inner_text.strip.encode("iso-8859-1").force_encoding("utf-8")
        img = doc.search('.product-image img')
        img_src = img[4]["src"] 
      else
        img_src = "https://www.mobileread.com/forums/attachment.php?attachmentid=111264&d=1378642555"
      end
      
      if price.nil? || title.nil? || author.nil?
        nil
      else
        book = Book.find_or_initialize_by(title: title, author: author, library: library, img_src: img_src, href: href, description: description)
        
        book.price = price
        
        if book.persisted?
          book.save
        end

        book
      end
    rescue
      nil
    end
  end

  def search_bookdep(search_term)
    url = "https://www.bookdepository.com/search?searchTerm=#{search_term}&search=Find+book"
    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)
      library = "Bookdepository"

      title = doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.search-page > div.content-block > div > div > div > div > div:nth-child(1) > div.item-info > h3 > a")

      if title.nil?
        img_src = "https://www.mobileread.com/forums/attachment.php?attachmentid=111264&d=1378642555"
      else
        title = doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.search-page > div.content-block > div > div > div > div > div:nth-child(1) > div.item-info > h3 > a").inner_text.strip
      

        author = doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.search-page > div.content-block > div > div > div > div > div:nth-child(1) > div.item-info > p.author > span > a > span")

        if author != nil
          author = author.inner_text.strip
        end

        url = doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.search-page > div.content-block > div > div > div > div > div:nth-child(1) > div.item-img > a")["href"]
        img_src = doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.search-page > div.content-block > div > div > div > div > div:nth-child(1) > div.item-img > a > img")["data-lazy"]
        
        price = doc.at_css("body > div.page-slide > div.content-wrap > div.main-content.search-page > div.content-block > div > div > div > div > div:nth-child(1) > div.item-info > div.price-wrap > p").inner_text.strip

        if price != ""
          price[0..2] = ""
          price = price.gsub(".", ",").strip.to_i
        end
        
        url[0] = ''
        first_part = url.split('/').first.parameterize
        last_part = "/#{url.split('/').last}"
        final_url = "/#{first_part}#{last_part}"
        href = "https://www.bookdepository.com/#{final_url}"
        html_content = open(href)
        doc = Nokogiri::HTML(html_content)
        
        
        description = doc.at_css("body > div.page-slide > div.content-wrap > div > div > div.item-wrap > div.item-description > div")

        if description != nil
          description = doc.at_css("body > div.page-slide > div.content-wrap > div > div > div.item-wrap > div.item-description > div").inner_text.split().join(" ").delete_suffix!(' show more')
        else
          description = "description not provided by library"
        end
      end

      url = "https://dolaraldia.com/"
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)

      usd = doc.at_css("#content-area > div > div.et_pb_section.et_pb_section_0.et_pb_with_background.et_section_regular > div.et_pb_row.et_pb_row_0 > div.et_pb_column.et_pb_column_1_3.et_pb_column_0.et_pb_css_mix_blend_mode_passthrough > div.et_pb_module.et_pb_code.et_pb_code_1.et_pb_text_align_left > div > div > div > div:nth-child(2) > div:nth-child(2)").inner_text.strip

      usd[0..1] = ""
      usd = usd.to_i
      usd = usd * 1.2
      usd = usd.to_i
      price = price * usd

      if price.nil? && title.nil? && author.nil?
        nil
      else
        book = Book.find_or_initialize_by(title: title, author: author, library: library, img_src: img_src, href: href, description: description)
        
        book.price = price
        
        if book.persisted?
          book.save
        end

        book
      end
    rescue
      nil
    end
  end

  def search_meli(search_term)
    search_term = search_term.gsub(" ", "-")
    url = "https://libros.mercadolibre.com.ar/libros/#{search_term}"
    img_src = "https://www.mobileread.com/forums/attachment.php?attachmentid=111264&d=1378642555"

    begin
      html_content = open(url)
      doc = Nokogiri::HTML(html_content)
      library = "Mercado Libre"
    
      title = doc.at_css("#root-app > div > div.ui-search-main.ui-search-main--exhibitor.ui-search-main--only-products > section > ol > li:nth-child(1) > div > div > div.ui-search-result__content-wrapper > div.ui-search-item__group.ui-search-item__group--title > a.ui-search-item__group__element.ui-search-link > h2").inner_text
      
      if title != nil
        img_src = doc.at_css("#root-app > div > div.ui-search-main.ui-search-main--exhibitor.ui-search-main--only-products > section > ol > li:nth-child(1) > div > div > div.ui-search-result__image > a > div > div > div > div > div > img")["data-src"]
        href = doc.at_css("#root-app > div > div.ui-search-main.ui-search-main--exhibitor.ui-search-main--only-products > section > ol > li:nth-child(1) > div > div > div.ui-search-result__image > a")["href"]

        html_content = open(href)
        doc = Nokogiri::HTML(html_content)
        
        price = doc.at_css("#root-app > div > div.ui-pdp-container.ui-pdp-container--pdp > div > div.ui-pdp-container__col.col-1.ui-pdp-container--column-right.mt-16.pr-16 > div.ui-pdp-container__row.ui-pdp-component-list.pr-16.pl-16 > div > div.ui-pdp-container__row.ui-pdp-container__row--price > div > div.andes-tooltip__trigger > div > span > span.price-tag-fraction").inner_text.gsub(".", "").to_i


        author = doc.at_css("#root-app > div > div.ui-pdp-container.ui-pdp-container--pdp > div > div.ui-pdp-container__col.col-2.ui-pdp-container--column-left.pb-40 > div.ui-pdp-container__col.col-1.ui-vip-core-container--content-left > div.ui-pdp-container__row.ui-pdp-container__row--technical-specifications > div > div.ui-pdp-specs__table > table > tbody > tr:nth-child(2) > td > span").inner_text.strip

        description = doc.at_css("#root-app > div > div.ui-pdp-container.ui-pdp-container--pdp > div > div.ui-pdp-container__col.col-2.ui-pdp-container--column-left.pb-40 > div.ui-pdp-container__col.col-1.ui-vip-core-container--content-left > div.ui-pdp-container__row.ui-pdp-container__row--description > div > p").inner_text.truncate(500)
      end

      if price.nil? || title.nil? || author.nil?
        nil
      else
        book = Book.find_or_initialize_by(title: title, author: author, library: library, img_src: img_src, href: href, description: description)
        
        book.price = price
        
        if book.persisted?
          book.save
        end

        book
      end
    rescue OpenURI::HTTPError => ex
      nil
    end
  end

  def search_description_and_rating(title)
    title = title.gsub("ñ", "n")
    url = "https://www.googleapis.com/books/v1/volumes?q=#{title}"
    response = RestClient.get url
    result = JSON.parse response.to_str
    book = {}
    if result["totalItems"] != 0
      rating = result['items'][0]['volumeInfo']['averageRating']
      description = result['items'][0]['volumeInfo']['description']
    else
      rating = "N/A"
      description = "N/A"
    end
    book[:rating] = rating
    book[:description] = description
    book
  end

  def search_online(title)
    title = title.parameterize
    cuspide = search_cuspide(title)
    hernandez = search_hernandez(title)
    yenny = search_yenny(title)
    bookdep = search_bookdep(title)
    meli = search_meli(title)
    description = search_description_and_rating(title)
    books = {}
    books[:cuspide] = cuspide
    books[:hernandez] = hernandez
    books[:yenny] = yenny
    books[:bookdep] = bookdep
    books[:meli] = meli
    books[:description] = description
    books[:title] = title
    books
  end
end
