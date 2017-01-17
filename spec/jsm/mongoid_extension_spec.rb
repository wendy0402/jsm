describe Jsm::EventExecutor::Mongoid do
  class UserMongoid
    include Mongoid::Document
    include Jsm::Client
    include Jsm::Client::Mongoid

    field :relationship, type: String
    field :name, type: String
    field :approved_by_parents, type: String

    attr_accessor :run_before, :run_after
  end

  before do
    UserMongoid.delete_all
  end

  include_examples "jsm extension spec", UserMongoid
end
