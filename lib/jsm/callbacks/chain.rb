# chain is a repository to store list of callbacks of an event, for example
# store before and after callback of an event called `run`
# e.g:
# before_callback =  Jsm::Callbacks::Callback.new(:before) do |user|
# log.info('before callback')
# end
# before_callback2 =  Jsm::Callbacks::Callback.new(:before) do |user|
#  user.age = 20
# end
# after_callback =  Jsm::Callbacks::Callback.new(:after) do |result, user|
#  log.info('after callback')
# end
# chain = Jsm::Callbacks::Chain.new(:run)
# chain.insert_callback(before_callback)
# chain.insert_callback(before_callback2)
# chain.insert_callback(after_callback)
# user = User.new
# result = chain.compile user do |user|
#  user.address = 'Indonesia'
# end
# result -> true
# log -> before callback after callback
# user.address -> 'Indonesia'

class Jsm::Callbacks::Chain
  attr_reader :context, :callbacks
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
  # before callback get arguments from *args
  # after callback get result of block execution and *args
  def arrange_callbacks(*args, &block)
    before = @callbacks.select { |callback| callback.filter_type == :before }
    after = @callbacks.select { |callback| callback.filter_type == :after }
    before.each { |callback| callback.execute(*args) }
    return_value = block.call(*args)
    after.each { |callback| callback.execute(return_value, *args) } if return_value
    return_value
  end
end
