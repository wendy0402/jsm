class Jsm::EventExecutor::ActiveModel < Jsm::EventExecutor::Base
  # it execute event for the object.
  # If transition failed or invalid by validation toward the object,
  # then it will return false
  def execute(event, obj)
    if can_be_executed?(event, obj)
      event.execute(obj)
    else
      false
    end
  end

  # check if the obj possible to execute the event
  def can_be_executed?(event, obj)
    state = event.can_be_transitioning_to(obj)
    attribute_name = obj.class.state_machine.attribute_name
    obj.valid?
    if state
      validators.validate(state.to, obj)
    else
      obj.errors.add(attribute_name, 'no transitions match')
    end
    obj.errors.empty?
  end
end
