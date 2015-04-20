require "speed_up_rails/engine"
require "speed_up_rails/request"

require 'rails'

require 'speed_up_rails/collectors/collector'

module SpeedUpRails

  def self.adapter
    @adapter
  end

  def self.adapter=(*adapter_options)
    adapter, *parameters = *Array.wrap(adapter_options).flatten

    @adapter = case adapter
    when Symbol
      adapter_class_name = adapter.to_s.camelize
      adapter_class =
        begin
          require "speed_up_rails/adapters/#{adapter}"
        rescue LoadError => e
          raise "Could not find adapter for #{adapter} (#{e})"
        else
          SpeedUpRails::Adapters.const_get(adapter_class_name)
        end
      adapter_class.new(*parameters)
    when nil
      SpeedUpRails::Adapters::Memory.new
    else
      adapter
    end

    @adapter
  end

  def self.enabled?
    # ['development', 'staging'].include?(Rails.env)
    !@temporary_disabled && !defined?(Rails::Console) && File.basename($0) != "rake"
  end

  def self.temporary_disabled=(val)
    @temporary_disabled = !!val
  end

  def self.setup_request(request_id)
    Thread.current[:speed_up_rails] = SpeedUpRails::Request.new(request_id)
  end

  def self.request
    Thread.current[:speed_up_rails]
  end

  def self.collectors=(collectors)
    collectors = Array.wrap(collectors)
    @collector_classes = collectors.map do |collector|
      collector_class_name = collector.to_s.camelize + 'Collector'
      require "speed_up_rails/collectors/#{collector}_collector"
      SpeedUpRails::Collectors.const_get(collector_class_name)
    end
  end

  def self.show_bar=(value)
    @show_bar = !!value
  end

  def self.show_bar?
    !!@show_bar
  end

  def self.prepare_collectors
    @collectors = @collector_classes.map{|col_kls| col_kls.new }
  end

  def self.collectors
    @collectors
  end

end

ActiveSupport.run_load_hooks(:speed_up_rails, SpeedUpRails) if SpeedUpRails.enabled?
