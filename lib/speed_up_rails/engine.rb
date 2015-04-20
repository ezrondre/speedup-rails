require 'speed_up_rails/controller_helpers'
require 'speed_up_rails/middleware'

module SpeedUpRails
  class Engine < ::Rails::Engine
    isolate_namespace SpeedUpRails

    engine_name :speed_up_rails

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    config.speed_up_rails = ActiveSupport::OrderedOptions.new

    # Default adapter
    config.speed_up_rails.adapter = :memory

    config.speed_up_rails.collectors = [:request, :queries]
    config.speed_up_rails.collectors += [:bullet, :rubyprof] if Rails.env.development?

    config.speed_up_rails.show_bar = true

    initializer 'speed_up_rails.set_configs' do |app|
      ActiveSupport.on_load(:speed_up_rails) do
        app.config.speed_up_rails.each do |k,v|
          send "#{k}=", v
        end
      end
    end

    initializer 'speed_up_rails.include_controller_helpers' do
      ActiveSupport.on_load(:action_controller) do
        include SpeedUpRails::ControllerHelpers
      end

      config.to_prepare do
        SpeedUpRails.prepare_collectors if SpeedUpRails.enabled?
      end
    end

    initializer "speed_up_rails.add_middleware" do |app|
      app.middleware.use 'SpeedUpRails::Middleware'
    end

  end
end
