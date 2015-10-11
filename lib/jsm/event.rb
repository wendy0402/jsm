class Jsm::Event
  attr_reader :name, :states, :transitions
  ::Jsm::Transition = Struct.new(:from, :to)
  def initialize(name, params = {})
    @name = name
    @states = params[:states]
    @transitions = []
  end

  def transition(params = {})
    validate_params(params)
    validate_state_transition(params)
    from = params[:from].is_a?(Array) ? params[:from] : [params[:from]]
    transition = Jsm::Transition.new(from, params[:to])
    @transitions.push(transition)
  end

  private

  def validate_params(params = {})
    from = params[:from]
    if (from.respond_to?(:empty) && from.empty?) || !from
      raise ArgumentError, "transition is invalid, missing from params"
    end

    to = params[:to]

    if (to.respond_to?(:empty) && to.empty?) || !to
      raise ArgumentError, "transition is invalid, missing to params"
    end
  end

  def validate_state_transition(params = {})
    from = Array(params[:from])
    to = params[:to]
    invalid_state = from.select {|state_name| !states.has_state?(state_name) }
    unless invalid_state.empty?
      raise Jsm::InvalidTransitionError, "'from' params is invalid. there is no state #{invalid_state.join(', ')} in list"
    end

    unless states.has_state?(to)
      raise Jsm::InvalidTransitionError, "'to' params is invalid. there is no state #{to} in list"
    end
  end
end
