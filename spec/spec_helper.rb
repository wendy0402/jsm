$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jsm'

RSpec.configure do |config|
  config.before :each do
    Jsm::Machines.class_variable_set(:@@machines, {})
  end
end
