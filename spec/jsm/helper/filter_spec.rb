class UserJsm
  extend Jsm::Helper::Filters

  def initialize
    @@sum = 0
  end

  def send_greeting
    @@sum += 1
  end

  def register_user(n = 2)
    @@sum += n
  end

  def send_mail
    @@sum += 3
  end

  def some_method(n = 4)
    @@sum += n
  end

  def some_other_method(n = 5)
    @@sum += n
  end

  def get_sum
    @@sum
  end
end

describe Jsm::Helper::Filters do
  it "hook before" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          before :send_greeting
        end
      end
    u_instance = u.new
    u_instance.register_user

    expect(u_instance.get_sum).to eq 3
  end

  it "hook after" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          after :send_mail
        end
      end
    u_instance = u.new
    u_instance.register_user

    expect(u_instance.get_sum).to eq 5
  end

  it "hook before and after" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          before :send_greeting
          after :send_mail
        end
      end
    u_instance = u.new
    u_instance.register_user

    expect(u_instance.get_sum).to eq 6
  end

  it "respecting the sending variable" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          before :send_greeting
          after :send_mail
        end
      end
    u_instance = u.new
    u_instance.register_user(10)

    expect(u_instance.get_sum).to eq 14
  end

  it "sending a block in before" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          before { some_method }
        end
      end
    u_instance = u.new
    u_instance.register_user

    expect(u_instance.get_sum).to eq 6
  end

  it "sending a complex block in before" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          before do
            some_method 5
            some_other_method 8
          end
        end
      end
    u_instance = u.new
    u_instance.register_user

    expect(u_instance.get_sum).to eq 15
  end

  it "sending a block in after" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          after { some_method }
        end
      end
    u_instance = u.new
    u_instance.register_user

    expect(u_instance.get_sum).to eq 6
  end

  it "sending a complex block in after" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          after do
            some_method 5
            some_other_method 8
          end
        end
      end
    u_instance = u.new
    u_instance.register_user

    expect(u_instance.get_sum).to eq 15
  end

  it "hook method return a value" do
    u = Class.new(UserJsm) do
        jsm_set_hook :register_user do
          after do
            some_method 5
            some_other_method 8
          end
        end
      end
    u_instance = u.new
    expect(u_instance.register_user).to eq 2
  end
end
