class BooksController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @books = Book.all
  end

  def show
    @book = Book.find(params[:id])
  end
end
