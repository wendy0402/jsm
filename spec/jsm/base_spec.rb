describe Jsm::Base do
  let(:state_machine) { Class.new(Jsm::Base) }

  describe '#state' do
    it 'can add new state' do
      state_machine.state :x
      expect(state_machine.states.map(&:name)).to match_array([:x])
    end

    # it 'can add new initial state' do
    #   state_machine.state :x, initial: true
    #   expect(state_machine.initial_state.name).to eq(:x)
    # end
    #
    # it 'can add many states with 1 initial state' do
    #   state_machine.state :x, initial: true
    #   state_machine.state :y
    #   expect(state_machine.initial_state.name).to eq(:x)
    #   expect(state_machine.states.map(&:name)).to match_array([:x, :y])
    # end
  end

  describe '#event' do
    before do
      state_machine.state :x#, initial: true
      state_machine.state :y
      state_machine.state :z

      state_machine.event :confirm do
        transition from: :x, to: :y
        transition from: :y, to: :z
      end
    end

    it 'register new event' do
      expect(state_machine.events[:confirm].name).to eq(:confirm)
    end

    it 'register the right transition' do
      expect(state_machine.events[:confirm].transitions[0].from).to eq([:x])
      expect(state_machine.events[:confirm].transitions[0].to).to eq(:y)
    end

    context 'raise exception' do
      it 'event with same name registered twice ' do
        expect{ state_machine.event :confirm do
          transition from: :y, to: :x
        end }.to raise_error(Jsm::InvalidEventError,"event confirm has been registered")
      end
    end
  end

  describe '.initialize' do
    let(:simple_model) {
      Class.new do
        attr_accessor :my_state
        def initialize(val = nil)
          @my_state = val
        end
        def self.state_machine
          SimpleSM
        end
      end
    }
    let(:state_machine) { SimpleSM }

    context 'attribute_name present' do
      it 'create custom events method for state model' do
        instance_model = state_machine.new(simple_model)
        expect(simple_model.new).to be_respond_to(:move)
        expect(simple_model.new).to be_respond_to(:backward)
      end

      it 'when custom event executed change state' do
        state_machine.new(simple_model)
        instance = simple_model.new(:x)
        expect{ instance.move }.to change{ instance.my_state }.from(:x).to(:y)
      end
    end

    context 'attribute_name is not present' do
      before do
        @origin_attribute_name = state_machine.attribute_name
        state_machine.instance_variable_set(:@attribute_name, nil)
      end

      after do
        state_machine.attribute_name @origin_attribute_name
      end

      it 'raise exception when state_machine attribute_name is nil' do
        expect{ state_machine.new(simple_model) }.to raise_error Jsm::NoAttributeError, "please assign the attribute_name first in class #{state_machine}"
      end
    end
  end
end
