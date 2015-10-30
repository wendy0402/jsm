describe Jsm::EventExecutor::ActiveModel do
  let(:simple_model) { create_class_active_model }
  let(:instance_model) { simple_model.new }
  let(:event_executor) { Jsm::EventExecutor::ActiveModel.new(state_machine: simple_sm) }
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

  before do
    simple_model.validate do |instance_model|
      errors.add(:age, 'is not allowed') if instance_model.age < 10
    end

    instance_model.my_state = :x
    instance_model.age = 20
  end

  describe '.execute' do
    context 'no validation' do
      it 'change state if transition can be done' do
        event_executor.execute(event, instance_model)
        expect(instance_model.current_state).to eq(:y)
      end
    end

    context 'with validation from jsm' do
      before do
        simple_sm.validate :y do |obj|
          if obj.name.nil?
            obj.errors.add :name, 'is wrong'
          end
        end
      end

      it 'if not valid, then dont do transition eventhough possible' do
        result = event_executor.execute(event, instance_model)
        expect(result).to be_falsey
        expect(instance_model.current_state).to eq(:x)
        expect(instance_model.errors[:name]).to include('is wrong')
      end

      it 'if valid, do transition' do
        instance_model.name = 'testMe'
        result = event_executor.execute(event, instance_model)
        expect(result).to be_truthy
        expect(instance_model.current_state).to eq(:y)
        expect(instance_model.errors[:name]).to be_empty
      end

      it 'when no transitions found, event failed' do
        instance_model.name = 'testMe'
        instance_model.my_state = :z
        result = event_executor.execute(event, instance_model)
        expect(result).to be_falsey
        expect(instance_model.current_state).to eq(:z)
        expect(instance_model.errors[:my_state]).to include('no transitions match')
      end
    end

    context 'callback' do
      before do
        simple_sm.before :action do |obj|
          obj.name = 'before'
        end

        simple_sm.after :action do |result, obj|
          obj.name += ' after'
        end
      end

      it 'run callback when execute event' do
        result = event_executor.execute(event, instance_model)
        expect(result).to be_truthy
        expect(instance_model.name).to eq('before after')
        expect(instance_model.my_state).to eq(:y)
      end
    end
  end

  describe 'can_be_executed' do
    before do
      simple_sm.validate :y do |obj|
        if obj.name != 'testMe'
          obj.errors.add(:name, 'is wrong')
        end
      end
    end

    it 'passed validation and transition is possible' do
      instance_model.name = 'testMe'
      expect(event_executor.can_be_executed?(event, instance_model)).to be_truthy
      expect(instance_model.errors).to be_empty
    end

    it 'validation exists and invalid return false' do
      instance_model.name = 'testMe2'
      expect(event_executor.can_be_executed?(event, instance_model)).to be_falsey
      expect(instance_model.errors[:name]).to include('is wrong')
    end

    it 'transition not found, return false' do
      instance_model.name = 'testMe'
      instance_model.my_state = :y
      expect(event_executor.can_be_executed?(event, instance_model)).to be_falsey
      expect(instance_model.errors[:my_state]).to include('no transitions match')
    end

    context 'validation from model class exist' do
      it "if it's failed, return false" do
        instance_model.age = 9
        result = event_executor.execute(event, instance_model)
        expect(result).to be_falsey
      end

      it 'if its failed didnt change the state' do
        instance_model.age = 9
        event_executor.execute(event, instance_model)
        expect(instance_model.current_state).to eq(:x)
      end

      it 'if its failed add the error message' do
        instance_model.age = 9
        event_executor.execute(event, instance_model)
        expect(instance_model.errors[:age]).to include("is not allowed")
      end

      it 'if its failed and validation state false add error message for both cases' do
        instance_model.age = 9
        event_executor.execute(event, instance_model)
        expect(instance_model.errors[:age]).to include("is not allowed")
        expect(instance_model.errors[:name]).to include("is wrong")
      end
    end
  end
end
