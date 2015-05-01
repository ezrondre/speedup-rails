module Speedup
  module Collectors
    class BulletCollector < Collector

      def initialize(*attrs)
        require 'bullet'
        Bullet.enable = true
        super
      end


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
        before_request do
          Bullet.start_request
        end
        after_request do
          Bullet.notification_collector && Bullet.notification_collector.collection.each do |notification|
            store_event(notification)
          end
          Bullet.end_request
        end
      end

      # use this method to keep convention
      def event_to_data(notification)
        {type: notification.class.name.split('::').last, name: notification.title, caller: notification.send(:call_stack_messages), message: notification.body}
      end


      # def filter_event?(evt)
      # end

    end
  end
end
