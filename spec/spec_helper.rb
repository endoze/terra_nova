require 'bundler/setup'
require 'terra_nova'
require 'pry'

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.before(:all) do
    Fog.mock!

    dns = Fog::DNS::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
    dns.create_hosted_zone('example.com.')
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
