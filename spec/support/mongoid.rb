# credit to Kaminari mongoid
# frozen_string_literal: true
# Ensure we use 'syck' instead of 'psych' in 1.9.2
# RubyGems >= 1.5.0 uses 'psych' on 1.9.2, but
# Psych does not yet support YAML 1.1 merge keys.
# Merge keys is often used in mongoid.yml
# See: http://redmine.ruby-lang.org/issues/show/4300
require 'mongoid'
require 'mongoid/version'

if RUBY_VERSION >= '1.9.2' && RUBY_VERSION < '2.2.0'
  YAML::ENGINE.yamler = 'syck'
end

Mongoid.configure do |config|
  hosts = ENV['MONGO_URL'] || '0.0.0.0:27017'
  if Mongoid::VERSION >= '5.0.0'
    config.load_configuration(
      clients: {
        default: {
          database: 'jsm_test',
          hosts: [ hosts ],
          options: { read: { mode: :primary }}
        }
      }
    )
  else
    config.sessions = {default: {hosts: [hosts], database: 'jsm_test'}}
  end
end
logger = Logger.new("mongoid.log")
Mongo::Logger.logger = logger
Mongoid.logger = logger
