Rails.application.routes.draw do
  root to: 'welcome#index'

  get '/error' => 'welcome#error'

  resources :posts

  mount SpeedUpRails::Engine => "/speed_up_rails"
end
