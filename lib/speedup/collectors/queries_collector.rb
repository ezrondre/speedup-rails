module  Speedup
  module Collectors
    class QueriesCollector < Collector


      def setup_subscribes
        register('sql.active_record')
      end

      def filter_event?(evt)
        evt.payload[:name] =~ /schema/i
      end

    end

  end
end
