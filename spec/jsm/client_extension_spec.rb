describe Jsm::ClientExtension do
  let(:simple_model) { create_class_simple_model }

  let(:instance_model) { simple_model.new }
  before do
    Jsm::ClientExtension.decorate(simple_model, state_machine: SimpleSM)
  end

  describe 'initialize' do
    it 'validators use event executor base class by default' do
      client_extension = Jsm::ClientExtension.new(simple_model, state_machine: SimpleSM)
      expect(client_extension.event_executor.class).to eq(Jsm::EventExecutor::Base)
    end

    it 'validators use event executor ActiveModel class if use client ActiveModel' do
      simple_model = create_class_active_model
      client_extension = Jsm::ClientExtension.new(simple_model, state_machine: SimpleSM)
      expect(client_extension.event_executor.class).to eq(Jsm::EventExecutor::ActiveModel)
    end
  end

  describe 'exception NoAttributeError' do
    before do
      @origin_attribute_name = SimpleSM.attribute_name
      SimpleSM.instance_variable_set(:@attribute_name, nil)
    end

    after do
      SimpleSM.attribute_name @origin_attribute_name
    end

    it 'raised when attribute_name empty' do
      expect{ Jsm::ClientExtension.new(simple_model, state_machine: SimpleSM) }.to raise_error Jsm::NoAttributeError
    end
  end

  describe 'state' do
    it 'create all states method for the object' do
      expect(instance_model).to respond_to(:x?)
      expect(instance_model).to respond_to(:y?)
      expect(instance_model).to respond_to(:z?)
    end

    it 'states method check if current state == states value in state method' do
      instance_model.my_state = :y
      expect(instance_model.y?).to be_truthy
      expect(instance_model.x?).to be_falsey
    end
  end

  describe 'event' do
    before do
      instance_model.my_state = :y
    end

    it 'define method to check whether object can run the event or not' do
      expect(instance_model).to respond_to(:can_move?)
      expect(instance_model).to respond_to(:can_backward?)
      expect(instance_model).to respond_to(:can_jump?)
    end
    context 'can event' do
      it 'return true if event is allowed' do
        expect(instance_model.can_backward?).to be_truthy
      end

      it 'return false if event is not allowed' do
        expect(instance_model.can_jump?).to be_falsey
      end
    end

    context 'run event' do
      it 'define method to run an event' do
        expect(instance_model).to respond_to(:move)
        expect(instance_model).to respond_to(:backward)
        expect(instance_model).to respond_to(:jump)
      end

      it 'run the method will trigger execution event' do
        expect{ instance_model.backward }.to change{ instance_model.current_state}.from(:y).to(:x)
      end

      it 'if state changed return true' do
        expect(instance_model.backward).to be_truthy
      end

      it 'if state changed return true' do
        expect(instance_model.move).to be_falsey
      end
    end

    context 'run event!' do
      it 'define method to run an event' do
        expect(instance_model).to respond_to(:move!)
        expect(instance_model).to respond_to(:backward!)
        expect(instance_model).to respond_to(:jump!)
      end

      it 'run the method will trigger execution event' do
        expect{ instance_model.backward! }.to change{ instance_model.current_state}.from(:y).to(:x)
      end

      it 'if state changed return true' do
        expect(instance_model.backward!).to be_truthy
      end
    end
  end
end
