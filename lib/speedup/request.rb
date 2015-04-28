require 'speedup-adapters'

module Speedup

  class Request

    def self.connection
      Speedup.adapter
    end

    def self.get(request_id)
      connection.get(request_id)
    end

    def initialize(request_id)
      @request_id = request_id
    end

    def id
      @request_id
    end

    def data
      @data ||= RequestData.new
    end

    def save
      Speedup.temporary_disabled = false
      return unless data.any?
      self.class.connection.write(id, data)
      File.open(Rails.root.join('tmp', 'test.yml'), 'w') {|f| f.write({contexts: data.contexts, data: data}.to_yaml) }
    end


    #data setters
    def request_data=(evt)
      storage = data.storage_for(:request)
      storage[:time] = evt.time
      storage[:duration] = evt.duration
      storage[:controller] = evt.payload[:controller]
      storage[:action] = evt.payload[:action]
      storage[:path] = evt.payload[:path]
      if evt.payload.key?(:exception)
        storage[:error] = true
        data.storage_for(:exception) << evt.payload[:exception]
      end
      storage[:view_duration] = evt.payload[:view_runtime]
      storage[:db_duration] = evt.payload[:db_runtime]
    end

    def store_event(evt)
      method = "store_#{evt.name.sub('.','_')}"
      if evt.name == 'process_action.action_controller'
        self.request_data = evt
      elsif respond_to?(method)
        send(method, evt)
      else
        data[:events][evt.name] ||= []
        data[:events][evt.name] << evt
      end
    end

    def store_sql_active_record(evt)
      queries = data.storage_for(:queries)
      queries << {time: evt.time, duration: evt.duration, name: evt.payload[:name], query: evt.payload[:sql]}
    end

    def store_bullet_notification(notification)
      bullet = data.storage_for(:bullet)
      bullet << {type: notification.class.name.split('::').last, name: notification.title, caller: notification.send(:call_stack_messages), message: notification.body}
    end

  end

end
