module Speedup
  module Collectors
    class RubyprofCollector < Collector

      def initialize(options={})
        require 'ruby-prof'
        @results_dir = Rails.root.join('tmp', 'rubyprof')
        Dir.mkdir( @results_dir ) unless File.directory?(@results_dir)
        super
      end

      def parse_options
        @profile_request = !!@options[:profile_request]
      end

      # The data results that are inserted at the end of the request for use in
      # deferred placeholders in the Peek the bar.
      #
      # Returns Hash.
      def results
        {}
      end

      def setup_subscribes
        if enabled? && @profile_request
          before_request do
            start_prof
          end
          after_request do
            end_prof
          end
        end
      end


      def filter_event?(evt)
        super || evt.payload[:controller].start_with?('Speedup')
      end

      def start_prof
        RubyProf.start
      end

      def end_prof(result_id=nil)
        result = RubyProf.stop

        Speedup.request.store_event(key, result_id )

        # Print a flat profile to text
        printer = printer_klass.new(result)
        ::File.open(@results_dir.join( Speedup.request.id + result_id.to_s + '.html' ), 'wb') do |file|
          printer.print(file)
        end
      end

      def profile(result_id=nil, &block)
        start_prof
        yield
        end_prof(next_id)
      end

      private

        def next_id
          @next_id = @next_id.to_i + 1
        end

        def printer_klass
          # RubyProf::GraphHtmlPrinter
          RubyProf::CallStackPrinter
        end

    end
  end
end
