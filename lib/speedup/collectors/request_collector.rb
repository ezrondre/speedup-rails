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
        evt.payload[:controller].start_with?('Speedup')
      end

    end
  end
end
