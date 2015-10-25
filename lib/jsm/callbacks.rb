module ::Jsm::Callbacks
  def self.included(base)
    base.instance_variable_set(:@jsm_callbacks,Jsm::Callbacks::ChainCollection.new(base))
    base.class_eval("def self.jsm_callbacks; @jsm_callbacks;end", __FILE__, __LINE__)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    def before(context, &block)
      callback = Jsm::Callbacks::Callback.new(:before, &block)
      self.jsm_callbacks[context].insert_callback(callback)
    end

    def after(context, &block)
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
