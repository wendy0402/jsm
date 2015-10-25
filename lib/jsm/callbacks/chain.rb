class Jsm::Callbacks::Chain
  attr_reader :context, :callbacks
  FILTER_TYPES_POSITION = [:before, :after]
  def initialize(context)
    @context = context
    @callbacks = []
  end

  def insert_callback(callback)
    @callbacks.push(callback)
  end

  def compile(*args, &block)
    arrange_callbacks(*args, &block)
  end

  private
  #run callbacks from before, given block then after callback
  # the return value is the original given block result
  def arrange_callbacks(*args, &block)
    before = @callbacks.select { |callback| callback.filter_type == :before }
    after = @callbacks.select { |callback| callback.filter_type == :after }
    before.each {|callback| callback.execute(*args) }
    return_value = block.call(*args)
    after.each { |callback| callback.execute(return_value, *args) }
    return_value
  end
end
