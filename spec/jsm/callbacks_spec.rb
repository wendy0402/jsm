describe Jsm::Callbacks do
  class SimpleCallbacks
    include Jsm::Callbacks
    attr_accessor :words
    before :upsize do |logger_io, name, number|
      logger_io.write "before "
    end

    after :upsize do |result, logger_io, name, number|
      logger_io.write "#{result} after"
    end

    def initialize
      @words = ''
    end

    def upsize(logger_io, name, number)
      run_callback :upsize, logger_io, name, number do
        @words += "#{name} on #{number}"
      end
    end

    def test_no_callbacks
      run_callback :no_callbacks do
        @words = 'test'
      end
    end
  end

  let(:simple_callback) { SimpleCallbacks.new }
  let(:logger_io) { StringIO.new }

  describe "run_callback" do
    context 'with callback' do
      before do
        simple_callback.upsize(logger_io, 'me', 'one')
      end

      it 'run the before and after callback' do
        expect(logger_io.string).to eq('before me on one after')
        expect(simple_callback.words).to eq('me on one')
      end
    end

    context 'without any callback defined for the context' do
      let(:result) { simple_callback.test_no_callbacks }
      before do
        result
      end

      it 'dont run any callback' do
        expect(logger_io.string).to eq('')
      end
      it 'still run the block' do
        expect(result).to eq('test')
      end
    end
  end
end
