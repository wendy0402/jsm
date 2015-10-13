# Jsm::ClientExtension define all custom methods for the model that use the state machine class
# E.g: Define method for states
class Jsm::ClientExtension
  def self.decorate(klass, params = {})
    client_extension = new(klass, params)
    client_extension.define_states_method
    client_extension.define_event_method
  end

  attr_reader :klass, :state_machine, :event_executor
  def initialize(klass, params = {})
    @klass = klass
    @state_machine = params[:state_machine]
    @event_executor = Jsm::EventExecutor.new
    unless @state_machine.attribute_name
      raise Jsm::NoAttributeError, "please assign the attribute_name first in class #{@state_machine.name}"
    end
  end

  # define method for all states to check status equal with a states
  # e.g: states: [:x, :y]
  # it will define method `x?` and `y?`
  def define_states_method
    state_machine.states.each do |state|
      state_name = state.name
      klass.send(:define_method, "#{state_name}?".to_sym) do
        self.current_state == state_name
      end
    end
  end

  # define all event that has been defined
  # it consists of 3 types of method:
  # * method to check whether can do event( e.g: can_married? )
  # * method to run an event and return bollean( e.g: married )
  # * method to run an event and raise error if failed( e.g: married! )
  def define_event_method
    state_machine.events.each do |event_name, event|
      event.attribute_name = state_machine.attribute_name
      define_can_event_method(event_name, event)
      define_event_execution_method(event_name, event)
      define_event_execution_method!(event_name, event)
    end
  end

  private
  def define_can_event_method(event_name, event)
    executor = event_executor
    klass.send(:define_method, "can_#{event_name}?") do
      executor.can_be_executed?(event, self)
    end
  end

  def define_event_execution_method(event_name, event)
    executor = event_executor
    klass.send(:define_method, "#{event_name}") do
      executor.execute(event, self)
    end
  end

  def define_event_execution_method!(event_name, event)
    executor = event_executor
    klass.send(:define_method, "#{event_name}!") do
      executor.execute!(event, self)
    end
  end
end
