module ClassGeneration
  def create_class_simple_model
    Class.new do
      attr_accessor :my_state, :name
      def initialize(val = nil)
        @my_state = val
      end
      def self.state_machine
        SimpleSM
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
