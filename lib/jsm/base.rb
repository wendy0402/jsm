# this module used as extension for state machine class
# The DSL is built to define the state, event, and transition that happen
class Jsm::Base
  def self.attribute_name(attribute_name = nil)
    if attribute_name.nil?
      @attribute_name
    else
      @attribute_name = attribute_name
    end
  end

  def self.state(name, params = {})
    @states ||= Jsm::States.new
    @states.add_state(name, initial: params[:initial])
  end

  def self.states
    @states.list
  end

  # def initial_state
  #   @states.initial_state
  # end

  def self.event(name, &block)
    @events ||= {}
    if !@events[name].nil?
      raise Jsm::InvalidEventError, "event #{name} has been registered"
    end

    @events[name] = Jsm::Event.new(name, states: @states, &block)
  end

  def self.events
    @events
  end

  def initialize(klass)
    @klass = klass
    create_custom_event_method
  end

  private

  def create_custom_event_method
    self.class.events.each do |name, event|
      @klass.class_eval <<-EOFDEF, __FILE__, __LINE__
        def #{name}
          #{event.execute(self)}
        end
      EOFDEF
    end
  end
end
