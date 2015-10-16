require 'active_record'
class ActiveRecordSM < Jsm::Base
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

  validate "married" do |user|
    unless user.approved_by_parents
      user.errors.add(:approved_by_parents, 'can not marry, you havent been approved')
    end
  end
end

ActiveRecord::Base.configurations = {
  'db1' => {
    :adapter  => 'sqlite3',
    :encoding => 'utf8',
    :database => ':memory:',
  }
}
ActiveRecord::Base.establish_connection(:db1)

class UserAR < ActiveRecord::Base
  include Jsm::Client
  include Jsm::Client::ActiveRecord
  self.table_name = 'users'

  validates_presence_of :age
  jsm_use ActiveRecordSM
end

UserAR.connection.drop_table('users') if UserAR.connection.table_exists?(:users)
UserAR.connection.create_table :users do |a|
  a.string :relationship
  a.string :name
  a.boolean :approved_by_parents
  a.text :age
end
