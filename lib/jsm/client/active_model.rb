module Jsm::Client::ActiveModel
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def current_state
      attr_state = state_machine.attribute_name
      send(attr_state)
    end
  end
end
