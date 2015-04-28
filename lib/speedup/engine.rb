require 'speedup/controller_helpers'
require 'speedup/middleware'

module Speedup
  class Engine < ::Rails::Engine
    isolate_namespace Speedup

    engine_name :speedup

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    config.speedup = ActiveSupport::OrderedOptions.new

    # Default adapter
    config.speedup.adapter = :memory

    config.speedup.collectors = [:request, :queries]
    config.speedup.collectors += [:bullet] if Rails.env.development?

    config.speedup.show_bar = true

    initializer 'speedup.set_configs' do |app|
      ActiveSupport.on_load(:speedup) do
        app.config.speedup.each do |k,v|
          send "#{k}=", v
        end
      end
    end

    initializer 'speedup.include_controller_helpers' do
      ActiveSupport.on_load(:action_controller) do
        include Speedup::ControllerHelpers
      end

      config.to_prepare do
        Speedup.prepare_collectors if Speedup.enabled?
      end
    end

    initializer "speedup.add_middleware" do |app|
      app.middleware.use 'Speedup::Middleware'
    end

  end
end
