# Jsm::Event handle event related task registered by the main module.
# It do transition process from one state to another state
class Jsm::Event
  attr_reader :name, :states, :transitions
  attr_accessor :attribute_name

  ::Jsm::Transition = Struct.new(:from, :to) do
    def multiple_from?
      from.size > 1
    end
  end

  def initialize(name, params = {}, &block)
    @name = name
    @states = params[:states]
    @transitions = []
    instance_eval(&block) if block_given?
  end

  # register a transition into the. When Event is executed,
  # these transitions is transitioning an object into `to` state,
  # if their current state match with one of the `from` state.
  # the argument input is params `from` and params `to`.
  # Both params should be exist
  def transition(params = {})
    validate_params(params)
    validate_state_transition(params)
    from = params[:from].is_a?(Array) ? params[:from] : [params[:from]]
    transition = Jsm::Transition.new(from, params[:to])
    @transitions.push(transition)
  end


  # execute the event, and do a transition
  # if the object current state match with the from state of a transition
  def execute(object)
    transition = can_be_transitioning_to(object)
    if transition
      change_state_obj(object, transition.to)
      true
    else
      false
    end
  end

  # check when running this event, which transitions can change the state of object state
  # return the transition object
  def can_be_transitioning_to(object)
    transitions.find{ |transition| transition.from.include?(obj_state(object)) }
  end

  # method to check whether this event can be executed
  def can_be_executed?(object)
    from_states = transitions.map(&:from).flatten
    from_states.include?(object.current_state)
  end

  private

  def obj_state(object)
    object.current_state
  end

  def change_state_obj(object, to_state)
    object.send("jsm_set_state", to_state)
  end

  def validate_params(params = {})
    from = params[:from]
    if (from.respond_to?(:empty) && from.empty?) || !from
      raise ArgumentError, "transition is invalid, missing required parameter from"
    end

    to = params[:to]

    if (to.respond_to?(:empty) && to.empty?) || !to
      raise ArgumentError, "transition is invalid, missing required parameter to"
    end
  end

  def validate_state_transition(params = {})
    from = Array(params[:from])
    to = params[:to]
    invalid_state = from.select {|state_name| !states.has_state?(state_name) }
    unless invalid_state.empty?
      raise Jsm::InvalidTransitionError, "parameter from is invalid. there is no state #{invalid_state.join(', ')} in list"
    end

    unless states.has_state?(to)
      raise Jsm::InvalidTransitionError, "parameter to is invalid. there is no state #{to} in list"
    end
  end
end
