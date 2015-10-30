class UserStateMachine < Jsm::Base
  attribute_name :relationship

  state :single, initial: true
  state :in_relationship
  state :married
  state :divorced
  state :widowed

  event :start_dating do
    transition from: :single, to: :in_relationship
  end

  event :marry do
    transition from: [:single, :in_relationship], to: :married
  end

  event :cheating do
    transition from: :in_relationship, to: :single
    transition from: :married, to: :divorced
  end

  event :divorce do
    transition from: :married, to: :divorced
  end

  before :marry do |obj|
    obj.name = 'testBefore'
  end

  after :marry do |result, obj|
    obj.name += ' testAfterthis'
  end
end


class UserBasic
  include Jsm::Client
  jsm_use UserStateMachine

  attr_accessor :relationship, :name
  def initialize(relationship = nil)
    @relationship = relationship
  end
end
