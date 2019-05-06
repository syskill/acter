# Acter

Acter is a command line client for HTTP APIs described by a JSON schema (cf. https://json-schema.org).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acter

## Usage

    $ acter <subject> <action> <args...>

Arguments may take the form `<param>=<value>` to set a request parameter, or `<Header>:<value>` to set an HTTP header for the request. As a special case, if the first argument does not contain `=` or `:`, it will be interpreted as `<subject>=<arg>`, i.e. the argument will be passed as a parameter named after the subject.

Ensure that the JSON schema describing your API is in a file named `schema.json` or `schema.yml` in the current directory. If not, you will have to specify a path or URL using the `-s` option.

To make acter your own, simply copy the executable or create a symlink with a new name.

### Advanced Usage

```ruby
schema_data = Acter.load_schema_data(SCHEMA_PATH_OR_URL)
begin
  action = Acter::Action.new(ARGV, schema_data)
rescue Acter::InvalidCommand => e
  Acter.handle_invalid_command(e)
  exit 1
end
result = action.send_request do |faraday_connection|
  ##
  ## apply middleware to connection or whatever
  ##
end
output = result.render(render_options) do |acter_response|
  ##
  ## return hash of conditional rendering options depending on the response,
  ## action, phase of the moon, etc.
  ##
end
puts output
exit 1 unless result.success?
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/syskill/acter.
