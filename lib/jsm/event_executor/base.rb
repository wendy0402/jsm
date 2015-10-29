# this class is the base for adapter
# it can be extended for ActiveRecord adapter
class Jsm::EventExecutor::Base
  attr_reader :validators, :state_machine
  def initialize(params = {})
    @state_machine = params[:state_machine]
    @validators = @state_machine.validators

  end

  # it execute event for the object.
  # If transition failed or invalid by validation toward the object,
  # then it will return false
  def execute(event, obj)
    state_machine.run_callback event.name, obj do |obj|
      execute_action(event, obj)
    end
  end

  # check if the obj possible to execute the event(passed the validation and can do transition)
  def can_be_executed?(event, obj)
    state = event.can_be_transitioning_to(obj)
    !!state && validators.validate(state.to, obj)
  end

  # same with execute, but if its failed raise error
  def execute!(event, obj)
    state_machine.run_callback event.name, obj do |obj|
      unless execute_action(event, obj)
        raise Jsm::IllegalTransitionError, "there is no matching transitions or invalid, Cant do event #{event.name}"
      end
      true
    end
  end

  private
  def execute_action(event, obj)
    can_be_executed?(event, obj) ? event.execute(obj) : false
  end
end
