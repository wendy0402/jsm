module Jsm::Client
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def self.included(base)
      base.class_eval <<-EOFILE, __FILE__, __LINE__
        private :jsm_set_state
      EOFILE
    end

    def state_machine
      self.class.respond_to?(:state_machine) ? self.class.state_machine : nil
    end

    # able to get current state from here instead check from the targeted attribute
    def current_state
      attr_state = state_machine.attribute_name
      instance_variable_get("@#{attr_state}".to_sym)
    end

    # used for set new state by JSM
    def jsm_set_state(val)
      attr_state = state_machine.attribute_name
      instance_variable_set("@#{attr_state}".to_sym, val)
    end
  end

  module ClassMethods
    def jsm_use(state_machine)
      self.class_eval <<-EODEF, __FILE__, __LINE__
        def self.state_machine
          #{state_machine}
        end
      EODEF
      Jsm::Machines.add_machines(self, state_machine.new(self))
    end

    # override method new
    # it is used for set the instance state attribute with initial_state
    # if initial_state present & instance state attribute is nil
    def new(*args, &block)
      obj = super
      initial_state = self.state_machine.initial_state

      if initial_state && !obj.current_state
        obj.send(:jsm_set_state, initial_state.name)
      end
      obj
    end

    #define type of event executor to be used
    def jsm_event_executor
      Jsm::EventExecutor::Base
    end
  end
end
