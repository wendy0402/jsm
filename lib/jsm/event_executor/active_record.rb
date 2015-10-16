class Jsm::EventExecutor::ActiveRecord < Jsm::EventExecutor::ActiveModel
  def execute(event, obj)
    if can_be_executed?(event, obj)
      result = false
      # do transaction to prevent shit happen
      ActiveRecord::Base.transaction do
        obj.class.lock
        event.execute(obj)
        result = obj.save
      end
      result
    else
      false
    end
  end
end
