module  Speedup
  module Collectors
    class QueriesCollector < Collector


      def setup_subscribes
        register('sql.active_record')
      end

      def filter_event?(evt)
        super || evt.payload[:name] =~ /schema/i
      end

      def event_to_data(evt)
        {time: evt.time, duration: evt.duration, name: evt.payload[:name], query: evt.payload[:sql], backtrace: clean_trace}
      end

    end

  end
end
