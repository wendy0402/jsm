describe Jsm::EventExecutor do
  let(:simple_model) { create_class_simple_model }
  let(:instance_model) { simple_model.new }
  let(:states) { Jsm::States.new }
  let(:event) { Jsm::Event.new(:action, states: states) }

  before do
    instance_model.my_state = :x
    states.add_state(:x)
    states.add_state(:y)
    event.transition from: :x, to: :y
  end

  describe '.execute' do
    context 'no validation' do
      let(:event_executor) { Jsm::EventExecutor.new }

      it 'change state if transition can be done' do
        event_executor.execute(event, instance_model)
        expect(instance_model.current_state).to eq(:y)
      end

      context 'with validation' do
        let(:validator) do
          Jsm::Validator.new(:state, :y) do |obj|
            obj.name == 'testMe'
          end
        end

        let(:validators) { Jsm::Validators.new }
        let(:event_executor) { Jsm::EventExecutor.new(validators: validators) }

        before do
          validators.add_validator(:y, validator)
        end

        it 'if not valid, then dont do transition eventhough possible' do
          result = event_executor.execute(event, instance_model)
          expect(result).to be_falsey
          expect(instance_model.current_state).to eq(:x)
        end

        it 'if valid, do transition' do
          instance_model.name = 'testMe'
          result = event_executor.execute(event, instance_model)
          expect(result).to be_truthy
          expect(instance_model.current_state).to eq(:y)
        end

        it 'when no transitions found, event failed' do
          instance_model.name = 'testMe'
          instance_model.my_state = :z
          result = event_executor.execute(event, instance_model)
          expect(result).to be_falsey
          expect(instance_model.current_state).to eq(:z)
        end
      end
    end
  end #describe .execute

  describe 'can_be_executed' do
    let(:validator) do
      Jsm::Validator.new(:state, :y) do |obj|
        obj.name == 'testMe'
      end
    end

    let(:validators) { Jsm::Validators.new }
    let(:event_executor) { Jsm::EventExecutor.new(validators: validators) }

    before do
      validators.add_validator(:y, validator)
    end

    it 'passed validation and transition is possible' do
      instance_model.name = 'testMe'
      expect(event_executor.can_be_executed?(event, instance_model)).to be_truthy
    end

    it 'validation exists and invalid return false' do
      instance_model.name = 'testMe2'
      expect(event_executor.can_be_executed?(event, instance_model)).to be_falsey
    end

    it 'transition not found, return false' do
      instance_model.name = 'testMe'
      instance_model.my_state = :y
      expect(event_executor.can_be_executed?(event, instance_model)).to be_falsey
    end
  end

  describe 'executed!' do
    let(:event_executor) { Jsm::EventExecutor.new }

    it 'if transition change current state' do
      result = event_executor.execute(event, instance_model)
      expect(result).to be_truthy
      expect(instance_model.current_state).to eq(:y)
    end

    it 'if transition failed return error' do
      instance_model.my_state = :z
      expect{ event_executor.execute!(event, instance_model) }.to raise_error Jsm::IllegalTransitionError, "there is no matching transitions, Cant do event action"
      expect(instance_model.current_state).to eq(:z)
    end
  end
end
