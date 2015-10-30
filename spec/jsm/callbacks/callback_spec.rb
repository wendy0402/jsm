describe Jsm::Callbacks::Callback do
  describe '.initialize' do
    it 'raise error if types not included in FILTER_TYPES' do
      expect{ Jsm::Callbacks::Callback.new(:mobile) }.to raise_error ArgumentError, "invalid type mobile, allowed: before, after"
    end

    it 'dont raise error if type is valid' do
      callback = Jsm::Callbacks::Callback.new(:before) do
        puts 'test'
      end

      expect(callback.filter_type).to eq(:before)
    end
  end
end
