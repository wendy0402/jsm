describe Jsm::Client do
  let(:example_simple_sm) do
    Class.new do
      include Jsm::Client
      jsm_use ::SimpleSM
      attr_accessor :my_state
      def initialize(state=nil)
        @my_state = state
      end
    end
  end

  it 'attach jsm class to class method state_machine' do
    expect(example_simple_sm.state_machine).to eq(SimpleSM)
  end

  describe 'current_state' do
    it 'refer to attribute name' do
      simple_sm = example_simple_sm.new(:y)
      expect(simple_sm.current_state).to eq(simple_sm.my_state)
    end
  end

  describe 'custom event method' do
    it 'create all the event method to ignite transition' do
      simple_sm = example_simple_sm.new(:y)
      expect(simple_sm).to be_respond_to(:move)
      expect(simple_sm).to be_respond_to(:jump)
    end
  end
end
