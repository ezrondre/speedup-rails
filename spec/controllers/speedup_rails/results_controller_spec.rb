require 'rails_helper'

module SpeedupRails
  RSpec.describe ResultsController, type: :controller do
    routes { SpeedupRails::Engine.routes }

    def initialize_request_data(request_id, adapter=:memory)
      Speedup.adapter = :memory
      Speedup.prepare_collectors
      data = YAML::load_file(File.expand_path('../../../data/test.yml', __FILE__))
      Speedup.adapter.write(request_id, Speedup::RequestData.new.load(data[:contexts], data[:data]) )
    end

    context 'with memory storage' do
      let(:request_id) { SecureRandom.hex(10) }

      before :each do
        initialize_request_data(request_id)
      end

      it 'renders a bar' do
        get :show, id: request_id
        expect(response).to be_success
      end

    end

  end
end
