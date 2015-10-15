module Jsm::Client::ActiveModel
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def current_state
      attr_state = state_machine.attribute_name
      send(attr_state)
    end

    def jsm_set_state(val)
      attr_state = state_machine.attribute_name
      send("#{attr_state}=", val)
    end
  end

  module ClassMethods
    def jsm_event_executor
      Jsm::EventExecutor::ActiveModel
    end
  end
end
