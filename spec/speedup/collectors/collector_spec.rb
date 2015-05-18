require 'speedup/collectors/collector'

module Speedup
  module Collectors

    describe Collector do

      subject { Collector.new }

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
          subscriber = subject.subscribe('.notification-test') do
            receiver.called_from_block
          end

          expect(receiver).to receive(:called_from_block)
          ActiveSupport::Notifications.instrument('.notification-test')

          ActiveSupport::Notifications.unsubscribe(subscriber)
        end
      end

      context '#register' do
        it 'store_event if registered event is fired' do
          expect(subject).to receive(:store_event)

          subscriber = subject.register('.notification-test')
          ActiveSupport::Notifications.instrument('.notification-test')
          ActiveSupport::Notifications.unsubscribe(subscriber)
        end
      end

    end

  end
end
