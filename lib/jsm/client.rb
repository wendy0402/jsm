module Jsm::Client
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def state_machine
      self.class.state_machine
    end

    def current_state
      attr_state = state_machine.attribute_name
      instance_variable_get("@#{attr_state}".to_sym)
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
  end
end
