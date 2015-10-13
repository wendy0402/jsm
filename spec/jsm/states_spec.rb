describe Jsm::States do
  let(:states) { Jsm::States.new }

  describe '.add_state' do
    it 'register new state' do
      states.add_state(:x)
      expect(states.list[0].name).to eq(:x)
    end

    it 'can register more than one state' do
      states.add_state(:x)
      states.add_state(:y)
      expect(states.list.map(&:name)).to match_array([:x, :y])
    end

    # it 'can register initial state' do
    #   states.add_state(:x, initial: true)
    #   expect(states.list[0].name).to eq(:x)
    #   expect(states.list[0].initial).to eq(true)
    # end
    #
    # it 'can register initial state with others states' do
    #   states.add_state(:w, initial: true)
    #   states.add_state(:x)
    #   states.add_state(:y)
    #   expect(states.list.map(&:name)).to match_array([:w, :x, :y])
    # end

    context 'exception' do
      before do
        states.add_state(:x, initial: true)
      end

      it 'register same state twice' do
        expect{ states.add_state(:x) }.to raise_error(Jsm::NotUniqueStateError, "state x has been defined")
      end

      # it 'register initial state twice' do
      #   expect { states.add_state(:y, initial: true) }.to raise_error(Jsm::InvalidStateError, 'can not set initial state to y. current initial state is x')
      # end
    end

    # it 'cannot register state without name' do
    #   expect{ states.add_state }.to raise_error(Jsm::InvalidStateError)
    # end
  end

  # describe '.initial_state' do
  #   before do
  #     states.add_state(:x, initial: true)
  #     states.add_state(:y)
  #   end
  #
  #   it 'value is the state with initial true' do
  #     expect(states.initial_state.name).to eq(:x)
  #   end
  # end

  describe 'has_state?' do
    context 'list has states' do
      before do
        states.add_state(:x, initial: true)
        states.add_state(:y)
      end

      it 'return true if state present' do
        expect(states.has_state?(:x)).to be_truthy
      end

      it 'return false if state doesnt present' do
        expect{ states.has_state?(:z).to be_falsey }
      end
    end

    context 'list doesnt have any state' do
      it { expect( states.has_state?(:y)).to be_falsey }
    end
  end
end
