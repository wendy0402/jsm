describe Jsm::Event do
  let(:simple_model) { create_class_simple_model }

  let(:states) { Jsm::States.new }

  describe '.initialize' do
    it 'require event name and states' do
      event = Jsm::Event.new(:event_test, states: states)
      expect(event.name).to eq(:event_test)
      expect(event.states).to eq(states)
    end
  end

  describe '.transition' do
    let(:event) { Jsm::Event.new(:event_test, states: states) }

    context 'state exists' do
      before do
        event
        states.add_state(:x)
        states.add_state(:y)
        states.add_state(:z)
      end

      it 'add transition need from and to' do
        event.transition from: [:x, :y], to: :z
        expect(event.transitions[0].from).to eq([:x, :y])
        expect(event.transitions[0].to).to eq(:z)
      end

      it 'can accept string' do
        event.transition from: :x, to: :y
        expect(event.transitions[0].from).to eq([:x])
        expect(event.transitions[0].to).to eq(:y)
      end
    end

    context 'exception' do
      before do
        event
        states.add_state(:x)
        states.add_state(:y)
        states.add_state(:z)
      end

      describe 'InvalidTransitionError' do
        it '`from` have state outside `states` list' do
          expect{ event.transition from: [:g, :x], to: :y }.to raise_error Jsm::InvalidTransitionError, "parameter from is invalid. there is no state g in list"
        end

        it 'all states in `from` is outside `states` list' do
          expect{ event.transition from: [:g, :t], to: :y }.to raise_error Jsm::InvalidTransitionError, "parameter from is invalid. there is no state g, t in list"
        end

        it '`from` string params outside state list' do
          expect{ event.transition from: :g, to: :y }.to raise_error Jsm::InvalidTransitionError, "parameter from is invalid. there is no state g in list"
        end

        it '`to` state is outside state list' do
          expect{ event.transition from: :x, to: :n }.to raise_error Jsm::InvalidTransitionError, "parameter to is invalid. there is no state n in list"
        end

        it '`from` and `to` state is outside state list' do
          expect{ event.transition from: :g, to: :n }.to raise_error Jsm::InvalidTransitionError
        end
      end

      describe 'ArgumentError' do
        it 'params from is empty' do
          expect{ event.transition to: :n }.to raise_error ArgumentError, "transition is invalid, missing required parameter from"
        end

        it 'params to is empty' do
          expect{ event.transition from: :n }.to raise_error ArgumentError, "transition is invalid, missing required parameter to"
        end
      end
    end
  end

  describe '.execute' do
    let(:event) { Jsm::Event.new(:event_test, states: states) }
    let(:instance) { simple_model.new }

    before do
      instance.my_state = :x
      event.attribute_name = :my_state
      states.add_state(:x)
      states.add_state(:y)
      states.add_state(:z)
      event.transition from: [:x, :y], to: :z
    end

    it "if transition 'from' match, transform object into `to` state" do
      event.execute(instance)
      expect(instance.my_state).to eq(:z)
    end
  end

  describe '.can_be_transitioning_to' do
    let(:event) { Jsm::Event.new(:event_test, states: states) }
    let(:instance) { simple_model.new }

    before do
      instance.my_state = :x
      event.attribute_name = :my_state
      states.add_state(:x)
      states.add_state(:y)
      states.add_state(:z)
      event.transition from: [:x, :y], to: :z
      event.transition from: [:y], to: :x
    end

    it "return transition that can be executed" do
      result = event.can_be_transitioning_to(instance)
      expect(result.to).to eq(:z)
      expect(result.from).to eq([:x, :y])
    end

    it 'return the first transition that match' do
      instance.my_state = :y
      result = event.can_be_transitioning_to(instance)
      expect(result.to).to eq(:z)
      expect(result.from).to eq([:x, :y])
    end
  end
end
