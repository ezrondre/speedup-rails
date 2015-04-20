module SpeedUpRails
  module Collectors
    class MiniprofilerCollector < Collector

      def initialize(*attrs)
        require 'rack-mini-profiler'
        Rack::MiniProfilerRails.initialize!(Rails.application)
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
      end


      # def filter_event?(evt)
      # end

    end
  end
end
