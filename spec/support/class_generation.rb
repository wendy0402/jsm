module ClassGeneration
  def create_class_simple_model
    Class.new do
      attr_accessor :my_state, :name, :age
      def initialize(val = nil)
        @my_state = val
      end

      def self.state_machine
        SimpleSM
      end

      def self.jsm_event_executor
        Jsm::EventExecutor::Base
      end

      def current_state
        my_state
      end

      def jsm_set_state(val)
        @my_state = val
      end
    end #class
  end #def

  def create_class_active_model
    Class.new do
      include ActiveModel::Model
      attr_accessor :my_state, :name, :age
      def initialize(val = nil)
        @my_state = val
      end

      def self.state_machine
        SimpleSM
      end

      def self.jsm_event_executor
        Jsm::EventExecutor::ActiveModel
      end

      def current_state
        my_state
      end

      def jsm_set_state(val)
        @my_state = val
      end
    end #class
  end #def
end
