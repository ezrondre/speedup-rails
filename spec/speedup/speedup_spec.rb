
describe Speedup do

  context '#collectors=' do

    it 'assigns collector options' do
      Speedup.collectors = [:request, {rubyprof: {profile_request: true}}]
      Speedup.prepare_collectors
      expect( Speedup.collectors.detect{|col| col.key == :rubyprof}.instance_variable_get(:@profile_request) ).to eq( true )
    end

    it 'prepare only one collector class per name' do
      Speedup.collectors = [:request, :rubyprof, {rubyprof: {profile_request: true}}]
      Speedup.prepare_collectors
      expect( Speedup.collectors.select{|col| col.key == :rubyprof}.size ).to eq( 1 )
      expect( Speedup.collectors.detect{|col| col.key == :rubyprof}.instance_variable_get(:@profile_request) ).to eq( true )
    end

  end

end
