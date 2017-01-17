describe ActiveRecord do
  ActiveRecord::Base.configurations = {
    'db1' => {
      :adapter  => 'sqlite3',
      :encoding => 'utf8',
      :database => ':memory:',
    }
  }
  ActiveRecord::Base.establish_connection(:db1)

  class User < ActiveRecord::Base
    include Jsm::Client
    include Jsm::Client::ActiveRecord

    attr_accessor :run_before, :run_after
  end

  before do
    User.connection.drop_table('users') if User.connection.table_exists?(:users)
    User.connection.create_table :users do |a|
      a.string :relationship
      a.string :name
      a.boolean :approved_by_parents
    end
  end

  include_examples "jsm extension spec", User
end
