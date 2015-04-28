module Speedup
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      helper_method :speed_up_rails_enabled?
    end

    protected

    def speed_up_rails_enabled?
      Speedup.enabled?
    end
  end
end
