describe Jsm::EventExecutor::Base do
  let(:simple_model) { create_class_simple_model }
  let(:instance_model) { simple_model.new }
  let(:simple_sm) do
    Class.new(Jsm::Base) do
      attribute_name :my_state
      state :x
      state :y
      event :action do
        transition from: :x, to: :y
      end
    end #class
  end
  let(:event) { simple_sm.events[:action] }
  let(:event_executor) { Jsm::EventExecutor::Base.new(state_machine: simple_sm) }
  before do
    instance_model.my_state = :x
  end

  describe '.execute' do
    context 'validation empty' do
      it 'change state if transition can be done' do
        event_executor.execute(event, instance_model)
        expect(instance_model.current_state).to eq(:y)
      end
    end

    context 'with validation' do
      before do
        simple_sm.validate :y do |obj|
          obj.name == 'testMe'
        end
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
    end # context

    context 'callbacks' do
      let(:logger_io) { StringIO.new }
      before do
        simple_sm.before :action do |obj|
          obj.name = 'before'
        end

        simple_sm.after :action do |result, obj|
          obj.name += ' after'
        end
      end

      it 'run the callbacks when run an event' do
        event_executor.execute(event, instance_model)
        expect(instance_model.my_state).to eq(:y)
        expect(instance_model.name).to eq('before after')
      end

      it 'doesnt run the after callback if execution fails' do
        instance_model.my_state = :y
        event_executor.execute(event, instance_model)
        expect(instance_model.name).to eq('before')
      end
    end
  end #describe .execute

  describe 'can_be_executed' do
    before do
      simple_sm.validate :y do |obj|
        obj.name == 'testMe'
      end
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
    it 'if transition change current state' do
      result = event_executor.execute(event, instance_model)
      expect(result).to be_truthy
      expect(instance_model.current_state).to eq(:y)
    end

    it 'if transition failed return error' do
      instance_model.my_state = :z
      expect{ event_executor.execute!(event, instance_model) }.to raise_error Jsm::IllegalTransitionError, "there is no matching transitions or invalid, Cant do event action"
      expect(instance_model.current_state).to eq(:z)
    end

    context 'callbacks' do
      before do
        simple_sm.before :action do |obj|
          obj.name = 'before'
        end

        simple_sm.after :action do |result, obj|
          obj.name += ' after'
        end
      end
      it 'run all callbacks when success and change state' do
        event_executor.execute!(event, instance_model)
        expect(instance_model.my_state).to eq(:y)
        expect(instance_model.name).to eq('before after')
      end

      it 'run before callbacks only when event failed' do
        instance_model.my_state = :z
        expect{ event_executor.execute!(event, instance_model)}.to raise_error Jsm::IllegalTransitionError,  "there is no matching transitions or invalid, Cant do event action"
        expect(instance_model.name).to eq('before')
      end
    end
  end
end
