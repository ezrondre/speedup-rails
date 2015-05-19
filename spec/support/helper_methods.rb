
module HelperMethods

  def stub_request
    request = double('request')
    allow(Speedup).to receive(:request).and_return(request)

    request
  end

  def stub_adapter
    adapter = double('adapter')
    allow(Speedup).to receive(:adapter).and_return(adapter)
    adapter
  end

  def prepare_event(name, data, duration=1.second)
    ActiveSupport::Notifications::Event.new(name, Time.now-duration, Time.now, SecureRandom.hex, data)
  end

end
