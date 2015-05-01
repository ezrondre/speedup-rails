module  Speedup
  module Collectors
    class PartialsCollector < Collector


      def setup_subscribes
        register('render_partial.action_view')
        register('render_collection.action_view')
      end

      # def filter_event?(evt)
      #   super || evt.payload[:name] =~ /schema/i
      # end

      def event_to_data(evt)
        data = super
        data[:identifier] = data[:identifier].gsub(Rails.root.to_s + '/', '')
        data
      end

    end

  end
end
