module Jsm
  require "jsm/version"
  require "jsm/states"
  require "jsm/event"
  require "jsm/exceptions"
  module EventExecutor
    require "jsm/event_executor/base"
    require "jsm/event_executor/active_model"
    require "jsm/event_executor/active_record"
    require "jsm/event_executor/mongoid"
  end

  require "jsm/callbacks"
  module Callbacks
    require 'jsm/callbacks/callback'
    require "jsm/callbacks/chain"
    require "jsm/callbacks/chain_collection"
  end
  require "jsm/base"
  require "jsm/client"
  require "jsm/client/active_model"
  require "jsm/client/active_record"
  require "jsm/client/mongoid"
  require "jsm/machines"
  require "jsm/client_extension"
  require "jsm/validator"
  require "jsm/validators"

  module Drawer
    require "jsm/drawer/node"
    require "jsm/drawer/digraph"
    require "jsm/drawer/graphviz"
  end
end
