describe Jsm::Validator do
  let(:user) { Class.new { attr_accessor :name } }
  let(:user_instance) { user.new }
  let!(:validator) do
    Jsm::Validator.new(:state, name: :x) do |user|
      user.name == 'testMe'
    end
  end

  it 'when valid return true' do
    user_instance.name = 'testMe'
    expect(validator.validate(user_instance)).to be_truthy
  end

  it 'when invalid return false' do
    user_instance.name = 'what'
    expect(validator.validate(user_instance)).to be_falsey
  end
end
