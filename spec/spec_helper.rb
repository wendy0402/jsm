$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jsm'
require 'active_record'
Dir[File.dirname(__FILE__) + "/models/*.rb"].sort.each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.before :each do
    Jsm::Machines.class_variable_set(:@@machines, {})
  end
end
