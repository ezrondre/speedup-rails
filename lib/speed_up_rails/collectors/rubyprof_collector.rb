module SpeedUpRails
  module Collectors
    class RubyprofCollector < Collector

      def initialize
        require 'ruby-prof'
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

      def render?
        false
      end

      def setup_subscribes
        before_request do
          RubyProf.start
        end
        after_request do
          result = RubyProf.stop

          # Print a flat profile to text
          printer = RubyProf::CallStackPrinter.new(result)
          ::File.open(Rails.root.join( 'tmp', SpeedUpRails.request.id ), 'wb') do |file|
            printer.print(file)
          end
        end
      end


      def filter_event?(evt)
        evt.payload[:controller].start_with?('SpeedUpRails')
      end

    end
  end
end
