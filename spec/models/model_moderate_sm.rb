class ModerateSM < Jsm::Base
  attribute_name :my_state
  state :x, initial: true
  state :y
  state :z

  validate :y do |obj|
    obj.name == 'testMe'
  end
  event :move do
    transition from: :x, to: :y
  end

  event :backward do
    transition from: :y, to: :x
  end

  event :jump do
    transition from: :x, to: :z
  end
end
