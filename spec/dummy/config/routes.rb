Rails.application.routes.draw do
  root to: 'welcome#index'

  get '/error' => 'welcome#error'
  get '/redirect' => 'welcome#redirect'

  resources :posts

  mount SpeedUpRails::Engine => "/speed_up_rails"
end
