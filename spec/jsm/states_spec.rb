describe Jsm::States do
  let(:state_model) { Class.new { attr_accessor :my_state}.new }

  describe '.initialize' do
    it 'require the base class model and column' do
      states = Jsm::States.new(state_model, :my_state)
      expect(states.object).to eq(state_model)
      expect(states.obj_column).to eq(:my_state)
    end
  end

  describe '.add_state' do
    let(:states) { Jsm::States.new(state_model, :my_state) }

    it 'register new state' do
      states.add_state(:x)
      expect(states.list[0].name).to eq(:x)
    end

    it 'can register initial state' do
      states.add_state(:x, initial: true)
      expect(states.list[0].name).to eq(:x)
      expect(states.list[0].initial).to eq(true)
    end

    context 'exception' do
      before do
        states.add_state(:x, initial: true)
      end

      it 'register same state twice' do
        expect{ states.add_state(:x) }.to raise_error(Jsm::NotUniqueStateError, "state x has been defined")
      end

      it 'register initial state twice' do
        expect { states.add_state(:y, initial: true) }.to raise_error(Jsm::InvalidStateError, 'can not set initial state to y. current initial state is x')
      end
    end

    # it 'cannot register state without name' do
    #   expect{ states.add_state }.to raise_error(Jsm::InvalidStateError)
    # end
  end

  describe '.initial_state' do
    let(:states) { Jsm::States.new(state_model, :my_state) }
    before do
      states.add_state(:x, initial: true)
      states.add_state(:y)
    end

    it 'value is the state with initial true' do
      expect(states.initial_state.name).to eq(:x)
    end
  end
end
