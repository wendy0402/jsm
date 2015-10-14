# describe ActiveRecord do
#   class ActiveRecordSM < Jsm::Base
#     attribute_name :relationship
#
#     state "single"
#     state "in_relationship"
#     state "married"
#     state "divorced"
#     state "widowed"
#
#     event :start_dating do
#       transition from: "single", to: "in_relationship"
#     end
#
#     event :marry do
#       transition from: ["single", "in_relationship"], to: "married"
#     end
#
#     event :cheating do
#       transition from: "in_relationship", to: "single"
#       transition from: "married", to: "divorced"
#     end
#
#     event :divorce do
#       transition from: "married", to: "divorced"
#     end
#
#     # validate "marry" do
#     #   errors.add(:married_at, 'is empty, please fill the married date') unless approved_by_parents
#     # end
#   end
#
#   ActiveRecord::Base.configurations = {
#     'db1' => {
#       :adapter  => 'sqlite3',
#       :encoding => 'utf8',
#       :database => ':memory:',
#     }
#   }
#   ActiveRecord::Base.establish_connection(:db1)
#
#   class User < ActiveRecord::Base
#     include Jsm::Client
#     include Jsm::Client::ActiveModel
#
#     jsm_use ActiveRecordSM
#   end
#
#   before do
#     User.connection.drop_table('users') if User.connection.table_exists?(:users)
#     User.connection.create_table :users do |a|
#       a.string :relationship
#       a.string :name
#       a.boolean :approved_by_parents
#       a.text :age
#     end
#   end
#
#   describe '.current state' do
#     it 'get the current value of the state' do
#       user = User.new(relationship: "single")
#       expect(user.current_state).to eq("single")
#     end
#   end
#
#   describe "validation" do
#     let(:user) { User.new(relationship: "single")}
#     context 'not valid' do
#       it 'dont run transition' do
#         expect(user.marry).to be_falsey
#       end
#
#       it 'add error message' do
#         user.marry
#         expect(user.errors[:approved_by_parents]).to be_present
#       end
#     end
#   end
# end
