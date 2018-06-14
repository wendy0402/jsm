describe Jsm::Callbacks::Chain do
  let(:chain) { Jsm::Callbacks::Chain.new(:save) }
  let(:logger_io) { StringIO.new }

  describe '.insert_callback' do
    it 'add more callback to list' do
      callback = Jsm::Callbacks::Callback.new :before do
        logger_io.info 'this is awesome'
      end
      chain.insert_callback(callback)
      expect(chain.callbacks[0]).to eq(callback)
    end
  end

  describe '.compile' do
    let(:klass) { Class.new {attr_accessor :word} }
    let(:callback_before) do
      Jsm::Callbacks::Callback.new :before do |logger_io|
        logger_io.write 'before'
      end
    end

    let(:callback_before2) do
      Jsm::Callbacks::Callback.new :before do |logger_io|
        logger_io.write ' before2'
      end
    end

    let(:callback_after) do
      Jsm::Callbacks::Callback.new :after do |result, logger_io|
        logger_io.write ' after'
      end
    end

    let(:callback_after2) do
      Jsm::Callbacks::Callback.new :after do |result, logger_io|
        logger_io.write ' after2'
      end
    end

    context 'callback before and after exists' do
      before do
        chain.insert_callback(callback_before)
        chain.insert_callback(callback_before2)
        chain.insert_callback(callback_after)
        chain.insert_callback(callback_after2)
      end

      it 'run all before callback before original block and all after run after the original block' do
        chain.compile logger_io do |logger_io|
          logger_io.write ' middle'
        end

        expect(logger_io.string).to eq('before before2 middle after after2')
      end

      context 'when given block fails' do
        it 'should not run the callback after' do
          chain.compile logger_io do |logger_io|
            false
          end

          expect(logger_io.string).to eq('before before2')
        end
      end
    end

    context 'callback before dont exist' do
      before do
        chain.insert_callback(callback_after)
      end

      it 'run the after callback' do
        chain.compile logger_io do |logger_io|
          logger_io.write ' middle'
        end

        expect(logger_io.string).to eq(' middle after')
      end
    end

    context 'callback after dont exist' do
      before do
        chain.insert_callback(callback_before)
      end

      it 'run the after callback' do
        chain.compile logger_io do |logger_io|
          logger_io.write ' middle'
        end

        expect(logger_io.string).to eq('before middle')
      end
    end

    describe 'return value' do
      before do
        chain.insert_callback(callback_before)
        chain.insert_callback(callback_after)
      end

      it 'is the original value in block given' do
        result = chain.compile logger_io do |logger_io|
          logger_io.write ' middle'
          'mobile'
        end

        expect(result).to eq('mobile')
      end
    end
  end
end
