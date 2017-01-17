class Jsm::EventExecutor::Mongoid < Jsm::EventExecutor::ActiveModel
  def execute_action(event, obj)
    return false unless can_be_executed?(event, obj)
    # do transaction to prevent shit happen
    event.execute(obj)
    obj.save
  end
end
