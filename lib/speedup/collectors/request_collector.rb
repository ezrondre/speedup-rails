module Speedup
  module Collectors
    class RequestCollector < Collector


      def parse_options
        # pass
      end

      # The data results that are inserted at the end of the request for use in
      # deferred placeholders in the Peek the bar.
      #
      # Returns Hash.
      def results
        {}
      end

      def setup_subscribes
        register('process_action.action_controller')
      end


      def filter_event?(evt)
        super || evt.payload[:controller].start_with?('Speedup')
      end

      def event_to_data(evt)
        data = {}
        data[:time] = evt.time
        data[:duration] = evt.duration
        data[:controller] = evt.payload[:controller]
        data[:action] = evt.payload[:action]
        data[:path] = evt.payload[:path]
        if evt.payload.key?(:exception)
          data[:error] = true
          Speedup.request.store_event(:exception, evt.payload[:exception] )
        end
        data[:view_duration] = evt.payload[:view_runtime]
        data[:db_duration] = evt.payload[:db_runtime]

        data
      end

    end
  end
end
