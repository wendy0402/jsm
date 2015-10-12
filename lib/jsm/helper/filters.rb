# this code isn't mine, I just change several method name and module name,
# because afraid of the method set_hook override other methods
# original code: https://github.com/TheBlasfem/garfio
module Jsm
  module Helper
    module Filters
      class FilterHooks
        attr_reader :hook_before, :hook_after
        def initialize(&block)
          instance_eval &block
        end

        private
        [:before, :after].each do |name|
          define_method name do |method_name = nil, &block|
            instance_variable_set("@hook_#{name}", method_name || block)
          end
        end
      end

      def jsm_set_hook(original_method, _v = "", &block)
        gar = FilterHooks.new &block
        send :alias_method, "old_#{original_method}", original_method
        send :define_method, original_method do |*args|
          _v.is_a?(Proc) ? instance_eval(&_v) : send(_v) if _v = gar.hook_before
          return_value = send "old_#{original_method}", *args
          _v.is_a?(Proc) ? instance_eval(&_v) : send(_v) if _v = gar.hook_after
          return_value
        end
      end #jsm_set_hook
    end # Filters
  end #helper
end #jsm
