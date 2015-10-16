module Jsm
  require "jsm/version"
  require "jsm/states"
  require "jsm/event"
  require "jsm/exceptions"
  require "jsm/machines"
  require "jsm/base"
  require "jsm/client"
  require "jsm/client/active_model"
  require "jsm/client/active_record"
  require "jsm/client_extension"
  require "jsm/validator"
  require "jsm/validators"

  module EventExecutor
    require "jsm/event_executor/base"
    require "jsm/event_executor/active_model"
    require "jsm/event_executor/active_record"
  end
end
