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
    include Jsm::Client::ActiveModel

    jsm_use ActiveRecordSM
  end

  before do
    User.connection.drop_table('users') if User.connection.table_exists?(:users)
    User.connection.create_table :users do |a|
      a.string :relationship
      a.string :name
      a.text :age
    end
  end

  describe '.current state' do
    it 'get the current value of the state' do
      user = User.new(relationship: "single")
      expect(user.current_state).to eq("single")
    end
  end
end
