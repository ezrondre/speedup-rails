SpeedUpRails::Engine.routes.draw do

  resources :results, only: [:show]
end
