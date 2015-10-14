class Jsm::Validator
  attr_reader :type, :name
  def initialize(type, name, &block)
    @type = type
    @name = name
    @block = block
  end

  def validate(obj)
    @block.call(obj)
  end
end
