class Jsm::Validators
  def initialize
    @list =  Hash.new { |validators, state| validators[state] = [] }
  end

  def add_validator(name, validator)
    @list[name].push(validator)
  end

  def [](name)
    @list[name]
  end

  def validate(name, obj)
    @list[name].all? { |validator| validator.validate(obj) }
  end
end
