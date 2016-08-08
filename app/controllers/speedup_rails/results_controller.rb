module SpeedupRails
  class ResultsController < SpeedupRails::ApplicationController

    def show
      @request_id = params[:id]
      @request = Speedup::Request.get(@request_id)
      if @request
        @collectors = Speedup.collectors
        @redirect = params[:redirect]
        render layout: false
      else
        render nothing: true, status: :not_found
      end
    end

    def rubyprof
      send_file Rails.root.join('tmp', 'rubyprof', params[:id] + params[:prof_id].to_s + '.html'), :type => 'text/html', :disposition => 'inline'
    end

  end
end
