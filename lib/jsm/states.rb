# Jsm::States job is to collect all states and validate new state
class Jsm::States
  attr_reader :object, :obj_column, :list
  ::Jsm::State = Struct.new(:name, :initial)

  # @param object: it's the base class that use the Jsm
  # @param obj_column: it's the base class column(or instance variable) that is affected by states
  def initialize(object, obj_column)
    @object = object
    @obj_column = obj_column
    @list = []
  end

  # register new state into the list
  # @param state_name
  # @param params: allowed params is `initial`(boolean value, default is false)
  def add_state(state_name, params = {})
    initial = params.fetch(:initial) { false }
    if !state_unique?(state_name)
      raise Jsm::NotUniqueStateError, "state #{state_name} has been defined"
    end

    if initial && !initial_state.nil?
      raise Jsm::InvalidStateError,"can not set initial state to #{state_name}. current initial state is #{initial_state.name}"
    end

    state = Jsm::State.new(state_name, initial)
    list.push(state)

    if state.initial
      @initial_state = state
    end
  end

  def initial_state
    @initial_state
  end

  private

  def state_unique?(state_name)
    list.all? {|state| state.name != state_name }
  end
end
