Rails.application.routes.draw do
  get 'movie/list'

  root 'dashboard#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
