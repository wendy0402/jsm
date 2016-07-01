[![Gem Version](https://badge.fury.io/rb/just_state_machine.svg)](https://badge.fury.io/rb/just_state_machine)
[![Code Climate](https://codeclimate.com/github/wendy0402/jsm/badges/gpa.svg)](https://codeclimate.com/github/wendy0402/jsm)
# Jsm

JSM is abbreviation of Just State Machine. The purpose is to simplify and increase the clarity of code related with state. JSM support validations before do transition. It help you to prevent unwanted transition. It also support integration with `ActiveModel` and `ActiveRecord`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'just_state_machine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install just_state_machine

## Usage

### State Machine Definition
To use `JSM`, a state machine class need to be created. Define your state machine here, such as:
* state
* event
* transition
* state validation
* attribute(the client state value)
* callback

```ruby
class UserStateMachine < Jsm::Base
  attribute_name :title

  state :beginner
  state :intermediate
  state :master

  validate :intermediate do |user|
	  (20..50).include?(user.current_level)
  end

  validate :master do |user|
	  user.current_level > 50
  end

  event :upgrade_title do
    transition from: [:beginner], to: :intermediate
    transition from: [:intermediate], to: :master
  end

  event :downgrade_title do
    transition from: :intermediate, to: :beginner
    transition from: :master, to: :intermediate
  end
end
```

### Client
To use the state machine definition specify it as below
```ruby
class User
  include Jsm::Client
  jsm_use UserStateMachine # your state machine class here

  attr_accessor :title # same with attribute_name in UserStateMachine
  #your code here
end
```
**note**: Client class should have instance variable same with `attribute_name` specified in state machine class.

This also provides you with a couple of public methods(based on event) for instances of the class `User`:
```ruby
user = User.new
user.upgrade_title # run event confirm, return true/ false
user.upgrade_title! # run event confirm, raise error Jsm::IllegalTransitionError if failed
user.can_upgrade_title? # check if can run event successfully, return true/false

user.downgrade_title
user.downgrade_title!
user.can_downgrade_title?
```
### State
Define your state **before** define others(validation, event, etc). It is to prevent you define transition, validation for unwanted state.
You can also define the `initial state`. Initial State is state value that is given when you don't set any value to state attribute in the instance on initialization. Initial State is optional.

```ruby
class UserStateMachine < Jsm::Base
  attribute_name :title

  state :beginner, initial: true
  state :intermediate
  state :master
# more code here
end

class User
  include Jsm::Client
  jsm_use UserStateMachine

  attr_accessor :title
  #your code here

  def initialize(title = nil)
    @title = title
  end
end

user = User.new
user.current_state # :beginner

user = User.new(:intermediate)
user.current_state # :intermediate
```
### Validation
This is useful, when you want to allow transition to a specified state allowed when it pass the validation. Validation should return true if passed validation and false if failed.
**note**: Dont forget to define the state first, because if not then Jsm will raise error `Jsm::InvalidStateError`. This is to prevent typo when add new validation
``` ruby
class UserStateMachine < Jsm::Base
# many codes here

  state :intermediate
  validate :intermediate do |user|
    (20..50).include?(user.current_level)
  end
# many codes here
end
```

### Event
when an event is triggered, it run `validate`. If passed, then it run `transition`. In the event of having multiple transitions, the first transition that successfully completes will stop other transitions to be executed.
```ruby
class UserStateMachine < Jsm::Base
  attribute_name :level

  state :beginner
  state :intermediate
  state :master

  event :upgrade_title do
    transition from: [:beginner], to: :intermediate
    transition from: [:intermediate], to: :master
  end

  event :downgrade_title do
    transition from: :intermediate, to: :beginner
    transition from: :master, to: :intermediate
  end


  before :upgrade_title do |user|
    user.name = 'before'
  end

  after :upgrade_title do |result, user|
    if result
      user.name += ' after success'
    else
      user.name += 'after failed'
    end
  end
end

# Client Class
class User
  include Jsm::Client
  jsm_use UserStateMachine # your state machine class here

  attr_accessor :title, :name # same with attribute_name in UserStateMachine
  def initialize
	  @title = :beginner
	  @level = 1
  end
  #your code here
end

user = User.new
user.title # :beginner
user.upgrade_title # true
user.title # :intermediate
```
### Transition
Transition will transitioning your state from one state to other state. Params `from` in transition can receive one or multiple states.
However to put multiple states, you need to put it in array.

```ruby
transition from: :intermediate, to: :beginner #one `from` states
transition from: [:intermediate, :master], to: :beginner #multiple `from` states
```
What above code means for multiple `from` states is the current state either `:intermediate` or `:master`, transform it into `:beginner` state

### Callbacks
`Jsm` now support callbacks. It provide 2 API: `before` and `after`. basically `before` callbacks is run before do event. Meanwhile, after callbacks is run after event. For **note**, after event first argument is `result` of the event
```ruby
class UserStateMachine < Jsm::Base
  attribute_name :level

  state :beginner
  state :intermediate
  state :master

  event :upgrade_title do
    transition from: [:beginner], to: :intermediate
    transition from: [:intermediate], to: :master
  end

  event :downgrade_title do
    transition from: :intermediate, to: :beginner
    transition from: :master, to: :intermediate
  end

  before :upgrade_title do |user|
    user.name = 'before'
  end

  after :upgrade_title do |result, user| # the first parameters is result of the event
    if result
      # execute if transition in event is success
      user.name += ' after success'
    else
      # execute if transition in event is failed
      user.name += 'after failed'
    end
  end
end

# Client Class
class User
  include Jsm::Client
  jsm_use UserStateMachine # your state machine class here

  attr_accessor :title, :name # same with attribute_name in UserStateMachine
  def initialize
	  @title = :beginner
	  @level = 1
  end
  #your code here
end

user = User.new
user.title # :beginner
user.name # nil
user.upgrade_title # true(it still return the original return value of the event)
user.name # before after success
```

## Active Model Integration
```ruby
class UserStateMachine < Jsm::Base
  attribute_name :title

  state :unconfirmed
  state :beginner
  state :intermediate
  state :master

  validate :intermediate do |user|
    unless (20..50).include?(user.current_level)
      user.errors.add(:title, 'is not between 20 and 50')
    end
  end

  validate :master do |user|
    unless user.current_level > 50
     user.errors.add(:title, 'have not reached 50')
    end
  end

  event :upgrade_title do
    transition from: [:beginner], to: :intermediate
    transition from: [:intermediate], to: :master
  end

  event :downgrade_title do
    transition from: :intermediate, to: :beginner
    transition from: :master, to: :intermediate
  end
end

# Client Class
class User
  include ActiveModel::Model
  include Jsm::Client
  include Jsm::Client::ActiveModel
  jsm_use UserStateMachine # your state machine class here

  attr_accessor :title # same with attribute_name in UserStateMachine
  attr_accessor :level
  def initialize
	@title = :beginner
	@level = 1
  end
  #your code here
end
```

`Jsm`  support `ActiveModel`. In the `client` class include the `Jsm::Client::ActiveModel`.  when run an event. It will auto saved the object.

### Validation
It also support validation from `ActiveModel` . Validation checked based on `errors` value in the `instance`. you can add an error to the errors object. This will prevent the state from being changed
```ruby
user = User.new
user.level # 1
user.level = 18
user.upgrade_title # false
user.errors[:title] # ["is not between 20 and 50"]
```
## ActiveRecord Integration
```ruby
class UserStateMachine < Jsm::Base
  attribute_name :title

  state :beginner
  state :intermediate
  state :master

  validate :intermediate do |user|
    unless (20..50).include?(user.current_level)
      user.errors.add(:title, 'is not between 20 and 50')
    end
  end

  validate :master do |user|
    unless user.current_level > 50
     user.errors.add(:title, 'have not reached 50')
    end
  end

  event :upgrade_title do
    transition from: [:beginner], to: :intermediate
    transition from: [:intermediate], to: :master
  end

  event :downgrade_title do
    transition from: :intermediate, to: :beginner
    transition from: :master, to: :intermediate
  end
end

# Client Class
class User < ActiveRecord::Base
  include Jsm::Client
  include Jsm::Client::ActiveRecord
  jsm_use UserStateMachine # your state machine class here

  attr_accessor :title # same with attribute_name in UserStateMachine
  attr_accessor :level
  def initialize
	@title = :beginner
	@level = 1
  end
  #your code here
end
```
`Jsm`  support `ActiveRecord`. In the `client` class include the `Jsm::Client::ActiveRecord`.  It also support `ActiveRecord` Validation. The behavior is same with `ActiveModel` client.


## Mongoid Integration

Mongoid use ActiveModel for validation etc. so you can use JSM integration with ActiveModel part

## StateMachine Visualization
When you want to visualize the state machine that has been defined. You can use the `Jsm::Drawer:Graphviz`. Basically it will generate an url for images of states diagram with theirs events. Basically the image is generated by `google chart`. They provide a really good API to generate state diagram.

```ruby
class UserStateMachine < Jsm::Base
  attribute_name :relationship

  state :single, initial: true
  state :in_relationship
  state :married
  state :divorced
  state :widowed

  event :start_dating do
    transition from: :single, to: :in_relationship
  end

  event :marry do
    transition from: [:single, :in_relationship], to: :married
  end

  event :cheating do
    transition from: :in_relationship, to: :single
    transition from: :married, to: :divorced
  end

  event :divorce do
    transition from: :married, to: :divorced
  end
end

Jsm::Drawer::Graphviz.generate_url(UserStateMachine) #the arguments is class name
```
the result will be:

![image](https://chart.googleapis.com/chart?cht=gv&chl=digraph{single-%3Ein_relationship[label=start_dating];single-%3Emarried[label=marry];in_relationship-%3Emarried[label=marry];in_relationship-%3Esingle[label=cheating];married-%3Edivorced[label=cheating];married-%3Edivorced[label=divorce]})

[source]( https://chart.googleapis.com/chart?cht=gv&chl=digraph{single-%3Ein_relationship[label=start_dating];single-%3Emarried[label=marry];in_relationship-%3Emarried[label=marry];in_relationship-%3Esingle[label=cheating];married-%3Edivorced[label=cheating];married-%3Edivorced[label=divorce]}Â)
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wendy0402/jsm. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
