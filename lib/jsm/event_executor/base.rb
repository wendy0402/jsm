# this class is the base for adapter
# it can be extended for ActiveRecord adapter
class Jsm::EventExecutor::Base
  attr_reader :validators
  def initialize(params = {})
    @validators = params[:validators] || Jsm::Validators.new
  end

  # it execute event for the object.
  # If transition failed or invalid by validation toward the object,
  # then it will return false
  def execute(event, obj)
    can_be_executed?(event, obj) ? event.execute(obj) : false
  end

  # check if the obj possible to execute the event(passed the validation and can do transition)
  def can_be_executed?(event, obj)
    state = event.can_be_transitioning_to(obj)
    !!state && validators.validate(state.to, obj)
  end

  # same with execute, but if its failed raise error
  def execute!(event, obj)
    unless event.execute(obj)
      raise Jsm::IllegalTransitionError, "there is no matching transitions, Cant do event #{event.name}"
    end
    true
  end
end
