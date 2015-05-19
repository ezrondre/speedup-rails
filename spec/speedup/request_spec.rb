require 'speedup/request'

module Speedup

  describe Request do

    let(:request_id) { SecureRandom.hex }
    let(:adapter) { stub_adapter }
    subject do
      r = Request.new(request_id)
      r.store_event(:request, duration: 3.seconds, time: Time.now - 3.seconds)
      r
    end

    context '#self.get' do
      it 'read data from adapter' do
        expect(adapter).to receive(:get).with(request_id)
        Request.get(request_id)
      end
    end

    context '#save' do
      it 'stores data to adapter' do
        expect(adapter).to receive(:write).with(request_id, kind_of(RequestData))
        subject.save
      end
    end

    context '#store_event' do
      it 'stores data for given key' do
        subject.store_event(:given_key, {some: 'data'})
        expect(subject.data[:given_key]).to eq([{some: 'data'}])
      end

      it 'stores data for given key to one array' do
        3.times do
          subject.store_event(:given_key, {some: 'data'})
        end
        expect(subject.data[:given_key]).to be_a_kind_of(Array)
        expect(subject.data[:given_key].count).to eq(3)
      end
    end

  end

end
