# this module used as extension for state machine class
# The DSL is built to define the state, event, and transition that happen
class Jsm::Base
  include Jsm::Callbacks
  # define attribute name of state attribute in the client class
  def self.attribute_name(attribute_name = nil)
    if attribute_name.nil?
      @attribute_name
    else
      @attribute_name = attribute_name
    end
  end

  # add new state to class
  # example
  # state :x
  # state :y
  # if put params initial true
  # it will be treated as initial_state
  # example:
  # state :x, initial: true
  def self.state(name, params = {})
    raw_states.add_state(name, initial: params[:initial])
  end

  # list of all states
  def self.states
    raw_states.list
  end

  # return initial_state
  # if empty return nil
  def self.initial_state
    raw_states.initial_state
  end

  # add new event to the class and add its transition
  # example:
  # event :do_this do
  # transition from: :x, to: :y
  # transition from: [:j, :g], to: :z
  def self.event(name, &block)
    @events ||= {}
    if !@events[name].nil?
      raise Jsm::InvalidEventError, "event #{name} has been registered"
    end

    @events[name] = Jsm::Event.new(name, states: @states, &block)
  end

  # get list of all events
  def self.events
    @events ||= {}
  end

  # add validation of a state(when changes to the targeted state, check whether passed this validation or not)
  # example:
  # state :y
  # validate :y do |obj|
  #   obj.name == 'testMe'
  # end
  def self.validate(state_name, &block)
    unless @states.has_state?(state_name)
      raise Jsm::InvalidStateError, "there is no state #{state_name}"
    end

    validators.add_validator(state_name, Jsm::Validator.new(:state, state_name, &block))
  end

  # list all validators that exist
  def self.validators
    @validators ||= Jsm::Validators.new
  end
  # set a before callback for an event
  def self.pre_before(event_name, &block)
    if !events[event_name]
      raise Jsm::InvalidEventError, "event #{event_name} has not been registered"
    end
  end

  def self.raw_states
    @states ||= Jsm::States.new
  end

  def initialize(klass)
    @klass = klass
    Jsm::ClientExtension.decorate(@klass, state_machine: self.class)
  end
end
