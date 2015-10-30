# the purpose of this class is to store the block that will be used as callback
# e.g:
# Jsm::Callbacks::Callback.new(:before) do
#   put 'me awesome'
# end

class Jsm::Callbacks::Callback
  FILTER_TYPES = [:before, :after]
  attr_reader :filter_type

  # the allowed filter_type: :before, :after
  def initialize(filter_type, &block)
    if FILTER_TYPES.include?(filter_type)
      @filter_type = filter_type
    else
      raise ArgumentError, "invalid type #{filter_type}, allowed: #{FILTER_TYPES.join(', ')}"
    end
    @block = block
  end

  # run callback
  def execute(*obj)
    @block.call(*obj)
  end
end
