require 'speedup/collectors/queries_collector'

module Speedup
  module Collectors

    describe QueriesCollector do
      subject { QueriesCollector.new }
      let!(:request) { stub_request }
      let(:query_data) { {name: 'Query count', sql: "SELECT COUNT(*) FROM query"} }

      context "subscribed events" do
        it 'stores an sql query event' do
          subject

          event_data = query_data.merge(query: query_data[:sql])
          event_data.delete(:sql)
          expect(request).to receive(:store_event).with(:queries, hash_including(event_data))
          ActiveSupport::Notifications.instrument('sql.active_record', query_data )
        end

        it 'filters schema queries' do
          subject

          expect(request).to_not receive(:store_event)
          ActiveSupport::Notifications.instrument('sql.active_record', name: 'ActiveRecord::SchemaMigration Load', sql: 'SELECT "schema_migrations".* FROM "schema_migrations"' )
          ActiveSupport::Notifications.instrument('sql.active_record', name: 'SCHEMA', sql: 'PRAGMA table_info("users")' )
        end
      end

      context '#event_to_data' do
        it 'should contain name, query, time and duration' do
          data = subject.event_to_data(prepare_event('sql.active_record', query_data))
          expect(data.keys).to include(:name, :query, :time, :duration)
        end
      end
    end

  end
end
