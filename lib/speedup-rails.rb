require "speedup-rails/engine"
require "speedup/request"

require 'rails'

require 'speedup/collectors/collector'

module Speedup

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
          require "speedup/adapters/#{adapter}"
        rescue LoadError => e
          raise "Could not find adapter for #{adapter} (#{e})"
        else
          Speedup::Adapters.const_get(adapter_class_name)
        end
      adapter_class.new(*parameters)
    when nil
      Speedup::Adapters::Memory.new
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
    Thread.current[:speedup_rails] = Speedup::Request.new(request_id)
  end

  def self.request
    Thread.current[:speedup_rails]
  end

  def self.collector_options
    @collector_options ||= {}
  end

  def self.collectors=(collectors)
    collector_names = Array.wrap(collectors).map do |collector|
      if collector.is_a?(Hash)
        collector_name = collector.keys.first
        collector_options[collector_name] = collector[collector_name]
        collector_name
      else
        collector
      end
    end.uniq

    @collector_classes = collector_names.map do |collector_name|
      collector_class_name = collector_name.to_s.camelize + 'Collector'
      require "speedup/collectors/#{collector_name}_collector"
      Speedup::Collectors.const_get(collector_class_name)
    end
  end

  def self.show_bar=(value)
    @show_bar = !!value
  end

  def self.show_bar?
    !!@show_bar
  end

  def self.automount=(value)
    @automount = !!value
  end

  def self.automount?
    !!@automount
  end

  def self.css=(value)
    @css = value
  end

  def self.css
    @css || {}
  end

  def self.prepare_collectors
    @collectors = @collector_classes.map{|col_kls| col_kls.new(collector_options[col_kls.key] || {}) }
  end

  def self.collectors
    @collectors
  end

  def self.profile(&block)
    @rubyprof ||= @collectors.detect{|c| c.key == :rubyprof}
    raise "You need to enable rubyprof collector to profile!" unless @rubyprof
    @rubyprof.profile(&block)
  end

end

ActiveSupport.run_load_hooks(:speedup, Speedup) if Speedup.enabled?
