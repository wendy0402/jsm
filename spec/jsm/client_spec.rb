describe Jsm::Client do
  let(:example_moderate_sm) do
    Class.new do
      include Jsm::Client
      jsm_use ::ModerateSM
      attr_accessor :my_state, :name
      def initialize(state=nil)
        @my_state = state
      end
    end
  end

  it 'attach jsm class to class method state_machine' do
    expect(example_moderate_sm.state_machine).to eq(ModerateSM)
  end

  describe '#initial_state' do
    context 'value exists' do
      it 'if state attribute_name is nil, use initial_state' do
        moderate_sm = example_moderate_sm.new
        expect(moderate_sm.current_state).to eq(:x)
      end

      it 'if state value in attribute_name is present, dont use initial_state' do
        moderate_sm = example_moderate_sm.new(:y)
        expect(moderate_sm.current_state).to eq(:y)
      end
    end

    context 'value doesnt exist' do
      let(:example_moderate_sm) do
        Class.new do
          include Jsm::Client
          jsm_use ::SimpleSM
          attr_accessor :my_state, :name
          def initialize(state=nil)
            @my_state = state
          end
        end
      end

      it 'use the defined value' do
        moderate_sm = example_moderate_sm.new(:y)
        expect(moderate_sm.current_state).to eq(:y)
      end

      it 'if state value in attribute_name is nil, then it will be nil' do
        moderate_sm = example_moderate_sm.new
        expect(moderate_sm.current_state).to be_nil
      end
    end
  end

  describe 'current_state' do
    it 'refer to attribute name' do
      moderate_sm = example_moderate_sm.new(:y)
      expect(moderate_sm.current_state).to eq(moderate_sm.my_state)
    end
  end

  describe 'custom event method' do
    it 'create all the event method to ignite transition' do
      moderate_sm = example_moderate_sm.new(:y)
      expect(moderate_sm).to be_respond_to(:move)
      expect(moderate_sm).to be_respond_to(:jump)
    end
  end
end
