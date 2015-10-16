module Jsm::Client::ActiveRecord
  def self.included(base)
    base.extend ClassMethods
    # Basically ActiveModel and ActiveRecord almost have the same behavior for its instance
    base.send(:include, Jsm::Client::ActiveModel::InstanceMethods)
  end

  module ClassMethods
    def jsm_event_executor
      Jsm::EventExecutor::ActiveRecord
    end
  end
end
