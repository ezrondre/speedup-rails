require 'speedup/collectors/collector'

module Speedup
  module Collectors

    describe Collector do

      subject { Collector.new }
      let(:event) { ActiveSupport::Notifications::Event.new('dummyevt', Time.now, Time.now + 1.second, SecureRandom.hex, {any: :data}) }

      context '#initialize' do
        it 'calls #parse_options' do
          expect_any_instance_of(Collector).to receive(:parse_options)
          subject
        end

        it 'calls #setup_subscribes' do
          expect_any_instance_of(Collector).to receive(:setup_subscribes)
          subject
        end

        it 'sets options passed' do
          options = {message: 'some nice message', time: Time.now}
          collector = Collector.new(options)
          expect( collector.instance_variable_get(:"@options") ).to eq(options)
        end
      end

      context '#subscribe' do

        it 'calls block passed in' do
          receiver = double('receiver')
          subscriber = subject.subscribe('!notification.test.speedup') do
            receiver.called_from_block
          end

          expect(receiver).to receive(:called_from_block)
          ActiveSupport::Notifications.instrument('!notification.test.speedup')

          ActiveSupport::Notifications.unsubscribe(subscriber)
        end
      end

      context '#register' do
        it 'store_event if registered event is fired' do
          expect(subject).to receive(:store_event)

          subscriber = subject.register('!notification.test.speedup')
          ActiveSupport::Notifications.instrument('!notification.test.speedup')
          ActiveSupport::Notifications.unsubscribe(subscriber)
        end

        it 'does not store_event if registered event is filtered out' do
          expect(subject).to receive(:filter_event?).and_return(true)
          expect(subject).to_not receive(:store_event)

          subscriber = subject.register('!notification.test.speedup')
          ActiveSupport::Notifications.instrument('!notification.test.speedup')
          ActiveSupport::Notifications.unsubscribe(subscriber)
        end
      end

      context '#store_event' do

        it 'store_event to the request with right_key' do
          request = double('request')
          expect(Speedup).to receive(:request).and_return(request)
          expect(subject).to receive(:key).and_return(:right_key)

          expect(request).to receive(:store_event).with(:right_key, kind_of(Hash))
          subject.store_event(event)
        end
      end

      context '#event_to_data' do
        it 'returns payload with time and duration' do
          expect( subject.event_to_data(event) ).to eq( event.payload.merge(time: event.time, duration: event.duration) )
        end
      end

    end

  end
end
