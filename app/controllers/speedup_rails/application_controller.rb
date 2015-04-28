module SpeedUpRails
  class ApplicationController < ActionController::Base

    before_action :disable_collectors

    private
      def disable_collectors
        SpeedUpRails.temporary_disabled = true
      end
  end
end
