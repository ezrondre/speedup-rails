
describe Speedup do

  context '#collectors=' do

    it 'assigns collector options' do
      Speedup.collectors = [:request, {rubyprof: {profile_request: true}}]
      Speedup.prepare_collectors
      expect( Speedup.collectors.detect{|col| col.key == :rubyprof}.instance_variable_get(:@profile_request) ).to eq( true )
    end

  end

end
