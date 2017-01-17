class ExtensionExampleSM < Jsm::Base
  attribute_name :relationship

  state "single"
  state "in_relationship"
  state "married"
  state "divorced"
  state "widowed"

  event :start_dating do
    transition from: "single", to: "in_relationship"
  end

  event :marry do
    transition from: ["single", "in_relationship"], to: "married"
  end

  event :cheating do
    transition from: "in_relationship", to: "single"
    transition from: "married", to: "divorced"
  end

  event :divorce do
    transition from: "married", to: "divorced"
  end

  before :marry do |obj|
    obj.name = 'before'
    obj.run_before = true
  end

  after :marry do |result, obj|
    obj.name += ' after'
    obj.run_after = true
  end

  validate "married" do |user|
    unless user.approved_by_parents
      user.errors.add(:approved_by_parents, 'can not marry, you havent been approved')
    end
  end
end
