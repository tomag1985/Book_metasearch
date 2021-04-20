Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'about', to: 'pages#about'

  get 'wishlist', to: 'pages#wishlist'

  post 'wishlist', to: 'pages#destroy'

  resources :books, only: [ :index, :show, :new, :create ]
end
