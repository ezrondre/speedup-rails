module SpeedupRails
  class ApplicationController < ActionController::Base

    before_filter :disable_collectors

    private
      def disable_collectors
        Speedup.temporary_disabled = true
      end
  end
end
