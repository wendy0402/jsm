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
    connection = User.connection
    ar_version = ActiveRecord.version
    table_present = (ar_version >= Gem::Version.new("5.0.0") ? connection.data_source_exists?(:users) : connection.table_exists?(:users))
    if table_present
      User.connection.drop_table('users')
    end

    User.connection.create_table :users do |a|
      a.string :relationship
      a.string :name
      a.boolean :approved_by_parents
    end
  end

  include_examples "jsm extension spec", User
end
