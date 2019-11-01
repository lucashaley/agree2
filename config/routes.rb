Rails.application.routes.draw do
  resources :reports
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/pages/:page" => "pages#show"
  get 'sessions/new'
  post 'sessions/create'
  get 'sessions/destroy'
  post '/statements/create_root' => "statements#create_root"

  resources :voters
  resources :authors
  resources :statements do
    collection do
      get :search
    end
    member do
      post :create_root
      post :create_child
      post :agree
      post :disagree
      post :toggle_agree
      get :image
    end
    resources :reports, only: [:create]
  end
  resources :statements, param: :parent_id do
    resources :statements, as: 'children', shallow: true
  end
  # resources :statements do
  #   resources :statements
  #   member do
  #     post :agree
  #   end
  # end

  # https://rubyplus.com/articles/4231-Tagging-using-Acts-as-Taggable-On-in-Rails-5
  get 'tags/:tag', to: 'statements#index', as: :tag

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "statements#home", page: "home"


end
