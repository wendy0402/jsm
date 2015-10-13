# Jsm::Event handle event related task registered by the main module.
# It do transition process from one state to another state
class Jsm::Event
  attr_reader :name, :states, :transitions
  attr_accessor :attribute_name

  ::Jsm::Transition = Struct.new(:from, :to)
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


  def execute(object)
    transitions.any? do |transition|
      if transition.from.include?(obj_state(object))
        change_state_obj(object, transition.to)
        return true
      end
      false
    end
  end

  def can_be_executed?(object)
    from_states = transitions.map(&:from).flatten
    from_states.include?(object.current_state)
  end

  private

  def obj_state(object)
    object.instance_variable_get("@#{attribute_name}".to_sym)
  end

  def change_state_obj(object, to_state)
    object.instance_variable_set("@#{attribute_name}", to_state)
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
