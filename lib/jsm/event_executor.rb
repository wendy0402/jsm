# this class is the base for adapter
# it can be extended for ActiveRecord adapter
class Jsm::EventExecutor
  attr_reader :validators
  def initialize(params = {})
    @validators = params[:validators]
  end

  # it execute event for the object.
  # If transition failed or invalid by validation toward the object,
  # then it will return false
  def execute(event, obj)
    if validators
      state = event.can_be_transitioning_to(obj)
      if state && validators.validate(state.to, obj)
        event.execute(obj)
      else
        false
      end
    else
      event.execute(obj)
    end
  end

  # check if the obj possible to execute the event
  def can_be_executed?(event, obj)
    state = event.can_be_transitioning_to(obj)
    if validators
      !!state && validators.validate(state.to, obj)
    else
      !!state
    end
  end

  # same with execute, but if its failed raise error
  def execute!(event, obj)
    unless event.execute(obj)
      raise Jsm::IllegalTransitionError, "there is no matching transitions, Cant do event #{event.name}"
    end
    true
  end
end
