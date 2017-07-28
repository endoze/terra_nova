# TerraNova

Tool to help automate building new EC2 servers on AWS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'terra_nova'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install terra_nova

## Usage

This gem is a command line tool to help build new EC2 servers on AWS. Once installed, you'll have access to the tool via the terra_nova command. It comes with a few built in subcommands to get you started.

```sh
Commands:
  terra_nova build-new-server [app] [environment] [domain]          # Build new ec2 instance for [app] in [environment] on [domain]
  terra_nova create-dns-entry [name] [value] [type] [ttl] [domain]  # Create dns entry for [name] [value] of type [type] with a ttl of [ttl] on [domain]
  terra_nova help [COMMAND]                                         # Describe available commands or one specific command
  terra_nova next-server-name [app] [environment] [domain]          # Get the next server name for [app] in [environment] on [domain]

Options:
  [--aws-key=AWS_KEY]        # AWS access key id
                             # Default: ENV['AWS_ACCESS_KEY_ID']
  [--aws-secret=AWS_SECRET]  # AWS secret access key
                             # Default: ENV['AWS_SECRET_ACCESS_KEY']
```

You will need to export you AWS credentials to your environment or pass them as options to the tool in order for everything to work.

TerraNova uses a yaml file to describe the different app servers it can build and their attributes. A sample yaml file looks like the following:

```yaml
prod:
  apps:
    my_app:
      ami_id: 'ami-4b133c5d'
      availability_zone: 'us-east-1e'
      block_device_mapping:
        device_name: '/dev/sda1'
        volume_size: 100
        delete_on_termination: true
      cloudwatch: true
      disable_api_termination: true
      ebs_optimized: true
      instance_type: 'c4.xlarge'
      key_name: 'some-keypair'
      region: 'us-east-1'
      security_group_id: ''
      subnet_id: ''
      tags: 
        App: <%= app %>
        Name: <%= next_server_name %>
        Monitored: <%= monitored %>
        Env: <%= environment %>
```

When evaluating the yaml file, a couple of variables are available to use to make your data generic.
The app, environment, monitoring status, and next_server_name can be used. TerraNova looks in the current directory for a file called infrastructure.yml when building a new server.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Endoze/terra_nova.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
