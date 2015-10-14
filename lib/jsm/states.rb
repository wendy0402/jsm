# Jsm::States job is to collect all states
class Jsm::States
  attr_reader :list
  ::Jsm::State = Struct.new(:name, :initial)

  def initialize
    @list = []
  end

  # register new state into the list
  # @param state_name
  def add_state(state_name, params = {})
    initial = params.fetch(:initial) { false }
    if !state_unique?(state_name)
      raise Jsm::NotUniqueStateError, "state #{state_name} has been defined"
    end

    state = create_state(state_name, initial)
    list.push(state)
  end

  def has_state?(state_name)
    list.any? { |state| state.name == state_name}
  end

  private

  def create_state(state_name, initial)
    Jsm::State.new(state_name, initial)
  end

  def state_unique?(state_name)
    list.all? {|state| state.name != state_name }
  end
end
