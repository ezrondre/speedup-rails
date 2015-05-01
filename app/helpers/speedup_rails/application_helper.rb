module SpeedupRails
  module ApplicationHelper

    def render_ms(value)
      ((value * 100).round.to_f / 100).to_s + ' ms'
    end

  end
end
