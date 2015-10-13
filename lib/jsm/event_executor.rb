# this class is the base for adapter
# it can be extended for ActiveRecord adapter
class Jsm::EventExecutor
  def execute(event, obj)
    event.execute(obj)
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
