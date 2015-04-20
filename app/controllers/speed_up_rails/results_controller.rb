module SpeedUpRails
  class ResultsController < SpeedUpRails::ApplicationController

    def show
      @request = SpeedUpRails::Request.get(params[:id])
      @collectors = SpeedUpRails.collectors
      render layout: false
    end

  end
end
