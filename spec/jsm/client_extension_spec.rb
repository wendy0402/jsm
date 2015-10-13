describe Jsm::ClientExtension do
  let(:simple_model) do
    Class.new do
      attr_accessor :my_state
      def current_state
        @my_state
      end
    end
  end

  let(:instance_model) { simple_model.new }
  before do
    Jsm::ClientExtension.decorate(simple_model, state_machine: SimpleSM)
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
    it 'create method to check whether object can run the event or not' do
      expect(instance_model).to respond_to(:can_move?)
      expect(instance_model).to respond_to(:can_backward?)
      expect(instance_model).to respond_to(:can_jump?)
    end
    context 'can event' do
      before do
        instance_model.my_state = :y
      end

      it 'return true if event is allowed' do
        expect(instance_model.can_backward?).to be_truthy
      end

      it 'return false if event is not allowed' do
        expect(instance_model.can_jump?).to be_falsey
      end
    end
  end
end
