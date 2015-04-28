SpeedupRails::Engine.routes.draw do

  resources :results, only: [:show] do
    get 'rubyprof', on: :member
  end
end
