class SimpleSM < Jsm::Base
  attribute_name :my_state
  state :x
  state :y
  state :z
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
