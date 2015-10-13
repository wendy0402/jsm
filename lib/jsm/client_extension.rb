class Jsm::ClientExtension
  def self.decorate(klass, params = {})
    client_extension = new(klass, params)
    client_extension.define_states_method
    client_extension.define_event_method
  end

  attr_reader :klass, :state_machine
  def initialize(klass, params = {})
    @klass = klass
    @state_machine = params[:state_machine]
  end

  def define_states_method
    state_machine.states.each do |state|
      state_name = state.name
      klass.send(:define_method, "#{state_name}?".to_sym) do
        self.current_state == state_name
      end
    end
  end

  def define_event_method
    state_machine.events.each do |event_name, event|
      define_can_event_method(event_name, event)
      define_event_execution_method(event_name, event)
      define_event_execution_method!(event_name, event)
    end
  end

  private
  def define_can_event_method(event_name, event)
    klass.send(:define_method, "can_#{event_name}?") do
      event.can_be_executed?(self)
    end
  end

  def define_event_execution_method(event_name, event)
    klass.send(:define_method, "#{event_name}") do
      event.execute(self)
    end
  end

  def define_event_execution_method!(event_name, event)
    klass.send(:define_method, "#{event_name}!") do
      unless event.execute(self)
        raise Jsm::IllegalTransitionError, "there is no matching transitions, Cant do event #{event_name}"
      end
      true
    end
  end
end
