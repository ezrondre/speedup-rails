Rails.application.routes.draw do
  root to: 'welcome#index'

  mount SpeedUpRails::Engine => "/speed_up_rails"
end
