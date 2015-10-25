class Jsm::Callbacks::Callback
  FILTER_TYPES = [:before, :after]
  attr_reader :filter_type
  def initialize(filter_type, &block)
    if FILTER_TYPES.include?(filter_type)
      @filter_type = filter_type
    else
      raise ArgumentError, "invalid type #{filter_type}, allowed: #{FILTER_TYPES.join(', ')}"
    end
    @block = block
  end

  def execute(*obj)
    @block.call(*obj)
  end
end
