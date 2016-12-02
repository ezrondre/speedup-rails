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
    config.speedup.collectors += [:bullet, :rubyprof] if Rails.env.development?
    config.speedup.collectors = [] if Rails.env.test?

    config.speedup.show_bar = Rails.env.development?
    config.speedup.automount = true

    config.speedup.css = {zindex: 10}

    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w(speedup_rails/icons.png)
      Rails.application.config.assets.paths << root.join("app", "assets", "images")
    end

    initializer 'speedup.set_configs' do |app|
      file = Rails.root.join('config', 'speedup-rails.yml')
      if File.exists?(file)
        file_config = YAML.load_file(file)[Rails.env]
        if file_config.is_a?(Hash)
          disable = file_config.delete('disabled_collectors')
          file_config.each do |key, val|
            app.config.speedup.send(key.to_s+'=', val)
          end
          Array(disable).each{|to_dis| app.config.speedup.collectors.delete(to_dis.to_sym) }
        end
      end

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
