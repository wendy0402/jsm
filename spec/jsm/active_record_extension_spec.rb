describe ActiveRecord do
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

    jsm_use ActiveRecordSM

    attr_accessor :run_before, :run_after
  end

  before do
    User.connection.drop_table('users') if User.connection.table_exists?(:users)
    User.connection.create_table :users do |a|
      a.string :relationship
      a.string :name
      a.boolean :approved_by_parents
      a.text :age
    end
  end

  describe '.current state' do
    it 'get the current value of the state' do
      user = User.new(relationship: "single")
      expect(user.current_state).to eq("single")
    end
  end

  describe "event method" do
    let(:user) { User.new(relationship: "single")}
    context 'not valid' do
      it 'dont run transition' do
        expect(user.marry).to be_falsey
        expect(user.errors[:approved_by_parents]).to include("can not marry, you havent been approved")
        expect(user.current_state).to eq("single")
      end
    end

    context 'valid' do
      before do
        user.approved_by_parents = true
      end

      it 'run transition' do
        expect(user.marry).to be_truthy
        expect(user.errors[:approved_by_parents]).to be_empty
        user.reload
        expect(user.current_state).to eq("married")
      end
    end

    context 'callbacks' do
      before do
        user.approved_by_parents = true
        user.marry
      end

      it 'run before callbacks before event is executed' do
        expect(user.name_was).to eq('before')
      end

      it 'run after callbacks after event is executed' do
        expect(user.name).to eq('before after')
      end

      it 'change the state' do
        expect(user.relationship).to eq("married")
      end
    end
  end

  describe 'can_event? method' do
    let(:user) { User.new(relationship: "single")}
    context 'not valid' do
      it 'dont run transition' do
        expect(user.can_marry?).to be_falsey
        expect(user.errors[:approved_by_parents]).to include("can not marry, you havent been approved")
      end
    end

    context 'valid' do
      before do
        user.approved_by_parents = true
      end

      it 'run transition' do
        expect(user.can_marry?).to be_truthy
        expect(user.errors[:approved_by_parents]).to be_empty
      end
    end
  end

  describe 'event! method' do
    let(:user) { User.new(relationship: "single")}
    context 'not valid' do
      it 'dont run transition' do
        expect{ user.marry! }.to raise_error Jsm::IllegalTransitionError, "there is no matching transitions or invalid, Cant do event marry"
        expect(user.errors[:approved_by_parents]).to include("can not marry, you havent been approved")
        expect(user.current_state).to eq("single")
      end

      it 'run before callback' do
        expect{ user.marry! }.to raise_error Jsm::IllegalTransitionError, "there is no matching transitions or invalid, Cant do event marry"
        expect(user.run_before).to be_truthy
      end

      it 'dont run the after callback' do
        expect{ user.marry! }.to raise_error Jsm::IllegalTransitionError, "there is no matching transitions or invalid, Cant do event marry"
        expect(user.run_after).to_not be_truthy
      end
    end

    context 'valid' do
      before do
        user.approved_by_parents = true
      end

      it 'run transition' do
        expect(user.marry!).to be_truthy
        expect(user.errors[:approved_by_parents]).to be_empty
        user.reload
        expect(user.current_state).to eq("married")
      end

      it 'run before callbacks before event is executed' do
        user.marry!
        expect(user.name_was).to eq('before')
      end

      it 'run after callbacks after event is executed' do
        user.marry!
        expect(user.name).to eq('before after')
      end

      it 'change the state' do
        user.marry!
        expect(user.relationship).to eq("married")
      end
    end
  end

  describe '.jsm_set_state' do
    it 'set the the state value' do
      user = User.new(relationship: "single")
      expect{ user.send(:jsm_set_state, "in_relationship") }.to change{ user.current_state }.from("single").to("in_relationship")
    end
  end
end
