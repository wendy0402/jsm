describe Jsm::Client::ActiveModel do
  class ActiveModelClient
    include ActiveModel::Model
    include Jsm::Client
    include Jsm::Client::ActiveModel
    jsm_use ModerateSM
    attr_accessor :my_state, :name
  end
  let(:instance) { ActiveModelClient.new(my_state: :x) }

  describe '.current_state' do
    it 'return current state' do
      expect(instance.current_state).to eq(:x)
    end
  end

  describe '.jsm_set_state' do
    it 'set the state' do
      expect{ instance.send(:jsm_set_state, :y) }.to change{ instance.current_state }.from(:x).to(:y)
    end
  end
end
