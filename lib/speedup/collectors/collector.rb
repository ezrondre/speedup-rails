module Speedup
  module Collectors
    class Collector

      def initialize(options = {})
        @options = options

        parse_options
        setup_subscribes
      end

      # Where any subclasses should pick and pull from @options to set any and
      # all instance variables they like.
      #
      # Returns nothing.
      def parse_options
        # pass
      end

      # Conditionally enable views based on any gathered data. Helpful
      # if you don't want views to show up when they return 0 or are
      # touched during the request.
      #
      # Returns true.
      def enabled?
        true
      end


      # Returns String.
      def key
        self.class.name.to_s.split('::').last.gsub(/Collector$/, '').underscore.to_sym
      end
      alias defer_key key

      def render?
        enabled?
      end


      # Returns String.
      def context_id
        "speedup-context-#{key}"
      end

      # The wrapper ID for the individual panel in the Speedup bar.
      #
      # Returns String.
      def dom_id
        "speedup-panel-#{key}"
      end

      # Additional context for any panel to render tooltips for.
      #
      # Returns Hash.
      def context
        {}
      end

      def context?
        context.any?
      end

      # The data results that are inserted at the end of the request for use in
      # deferred placeholders in the Speedup the bar.
      #
      # Returns Hash.
      def results
        {}
      end

      def results?
        results.any?
      end

      def subscribe(*args, &block)
        ActiveSupport::Notifications.subscribe(*args, &block)
      end

      def register(*args)
        subscribe(*args) do |*args|
          next unless Speedup.enabled?
          evt = ActiveSupport::Notifications::Event.new(*args)
          Speedup.request.store_event(evt) unless filter_event?(evt)
        end
      end

      def filter_event?(evt)
        Speedup.enabled?
      end

      protected

        def setup_subscribes
          # pass
        end

        # Helper method for subscribing to the event that is fired when new
        # requests are made.
        def before_request(&block)
          subscribe 'start_processing.action_controller', &block
        end

        # Helper method for subscribing to the event that is fired when requests
        # are finished.
        def after_request(&block)
          subscribe 'process_action.action_controller', &block
        end

    end
  end
end
