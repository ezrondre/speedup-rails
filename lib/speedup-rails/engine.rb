require 'speedup/controller_helpers'
require 'speedup/middleware'

module SpeedupRails
  class Engine < ::Rails::Engine
    isolate_namespace SpeedupRails

    engine_name :speedup

    def self.automount!(path = nil)
      engine = self
      path ||= engine.to_s.underscore.split('/').first
      Rails.application.routes.draw do
        mount engine => path
      end
    end

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      g.assets false
      g.helper false
    end

    config.speedup = ActiveSupport::OrderedOptions.new

    # Default adapter
    config.speedup.adapter = Rails.env.development? ? :memory : :file

    config.speedup.collectors = [:request, :queries, :partials]
    config.speedup.collectors += [:bullet] if Rails.env.development?
    config.speedup.collectors = [] if Rails.env.test?

    config.speedup.show_bar = Rails.env.development?
    config.speedup.automount = true

    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w(speedup_rails/icons.png)
      Rails.application.config.assets.paths << root.join("app", "assets", "images")
    end

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
      app.middleware.insert_after 'ActionDispatch::RequestId', 'Speedup::Middleware'
    end

  end
end
