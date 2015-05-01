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
    end


    def store_event(key, evt_data)
      method = "store_#{key}"
      if key == :request
        data.storage_for(key).merge!(evt_data)
      elsif respond_to?(method)
        send(method, evt_data)
      else
        storage = data.storage_for(key)
        storage << evt_data
      end
    end

  end

end
