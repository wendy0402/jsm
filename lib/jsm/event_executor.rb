# this class is the base for adapter
# it can be extended for ActiveRecord adapter
class Jsm::EventExecutor
  attr_reader :validators
  def initialize(params = {})
    @validators = params[:validators]
  end

  def execute(event, obj)
    if !validators.nil?
      state = event.can_be_transitioning_to(obj)
      validators.validate(state.to, obj) ? event.execute(obj) : false
    else
      event.execute(obj)
    end
  end

  def can_be_executed?(event, obj)
    event.can_be_executed?(obj)
  end

  def execute!(event, obj)
    unless event.execute(obj)
      raise Jsm::IllegalTransitionError, "there is no matching transitions, Cant do event #{event.name}"
    end
    true
  end
end
