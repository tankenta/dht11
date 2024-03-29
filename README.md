# DHT11

Ruby conversion of [DHT11 Python library](https://github.com/szazo/DHT11_Python) which depends only on [rpi_gpio](https://github.com/ClockVapor/rpi_gpio).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dht11'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dht11

## Usage

```ruby
require 'dht11'

dht = DHT11::Sensor.new(26)	# BCM numbering
result = dht.read
puts "Temperature: #{result.temperature}, Humidity: #{result.humidity}"
```

You can also try running the binary as:

    $ bundle exec bin/dht11

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tankenta/dht11.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
