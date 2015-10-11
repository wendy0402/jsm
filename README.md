# Jsm

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/jsm`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsm

## Usage

JSM is Just State Machine. The purpose is to simplify and increase the clarity of code related with state. JSM support validation in `ActiveModel::Model`. Many great gem related with state machine, mostly can not do this, so I build this JSM. to use it follow this:

```ruby
class UserStateMachine
  include Jsm::Base
  include Jsm::ActiveModel

  column_name :level

  state :unconfirmed, initial: true
  state :beginner
  state :intermediate
  state :master

  validation :beginner do
    validate :registration_validation do |user|
      user.errors.add(:email_confirmation, 'has not been done yet') if user.confirmation.blank?
      user.errors.add(:address, 'can not be blank') if user.address.blank?
    end
  end

  validation :intermediate do
    validate :completion_beginner_level_validation do |base|
      unless user.current_level == min_level_intermediate
        user.errors.add(:base, 'Please complete all beginner task')
      end
    end
  end

  validation :master do
    validates :completion_intermediate_level_validation do |base|
      unless user.current_level == total_complete_intermediate
        errors.add(:base, 'Please complete all intermediate task')
      end
    end
  end

  event :confirm do
    transition from: [:unconfirmed], to: :beginner
  end

  event :level_up do
    transition from: [:beginner], to: :intermediate
    transition from: [:intermediate], to: :master
  end
end

class User < ActiveRecord::Base
  include Jsm::DSL
  use_jsm UserStateMachine
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jsm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
