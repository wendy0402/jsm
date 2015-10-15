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
      end
    end
  end
end
