module Speedup
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      helper_method :speedup_rails_enabled?
    end

    protected

    def speedup_rails_enabled?
      Speedup.enabled?
    end
  end
end
