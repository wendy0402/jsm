module ::Jsm::Callbacks
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    def jsm_callbacks
      @jsm_callbacks ||= Jsm::Callbacks::ChainCollection.new(self)
    end
    #override this to do something before method `before`
    def pre_before(context, &block)
    end

    #override this to do something before method `after`
    def pre_after(context, &block)
    end

    # this method is to register a `before callback` to a jsm_callbacks
    def before(context, &block)

      pre_before(context, &block)
      callback = Jsm::Callbacks::Callback.new(:before, &block)
      jsm_callbacks[context] ||= Jsm::Callbacks::Chain.new(context)
      jsm_callbacks[context].insert_callback(callback)
    end

    # this method is to register a `after callback` to a jsm_callbacks
    def after(context, &block)
      pre_after(context, &block)
      callback = Jsm::Callbacks::Callback.new(:after, &block)
      self.jsm_callbacks[context].insert_callback(callback)
    end
  end

  module InstanceMethods
    def run_callback(context, *args, &block)
      self.class.jsm_callbacks[context].compile(*args, &block)
    end
  end
end
