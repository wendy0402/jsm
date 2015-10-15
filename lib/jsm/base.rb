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

  def self.validate(state_name, &block)
    @validators ||= Hash.new {|validators, state| validators[state] = []}
    @validators[state_name].push(Jsm::Validator.new(:state, state_name, &block))
  end

  def self.validators
    @validators
  end

  def initialize(klass)
    @klass = klass
    Jsm::ClientExtension.decorate(@klass, state_machine: self.class)
  end
end
