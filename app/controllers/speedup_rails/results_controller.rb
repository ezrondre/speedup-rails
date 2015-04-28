module SpeedUpRails
  class ResultsController < SpeedUpRails::ApplicationController

    def show
      @request_id = params[:id]
      @request = SpeedUpRails::Request.get(@request_id)
      @collectors = SpeedUpRails.collectors
      @redirect = params[:redirect]
      render layout: false
    end

    def rubyprof
      send_file Rails.root.join('tmp', 'rubyprof', params[:id] ), :type => 'text/html', :disposition => 'inline'
    end

  end
end
