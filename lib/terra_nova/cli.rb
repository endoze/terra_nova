require 'thor'

module TerraNova
  class CLI < Thor
    class_option :aws_key, type: :string,
      default: ENV['AWS_ACCESS_KEY_ID'],
      desc: "AWS access key id"
    class_option :aws_secret, type: :string,
      default: ENV['AWS_SECRET_ACCESS_KEY'],
      desc: "AWS secret access key"

    desc "build-new-server [app] [environment] [domain]",
      "Build new ec2 instance for [app] in [environment] on [domain]"
    method_option :monitored, type: :boolean,
      default: false, desc: "Enable Netuitive monitoring"
    def build_new_server(app, environment, domain)
      server_attributes = BuildNewServer.new(
        app: app,
        environment: environment,
        domain: domain,
        options: options,
      ).call

      puts server_attributes
      puts ""

      if !server_attributes.empty?
        if server_attributes[:provision_script]
          puts 'Run the following to provision the server:'
          puts "  #{server_attributes[:provision_script]}"
        end
      end
    end

    desc "next-server-name [app] [environment] [domain]",
      "Get the next server name for [app] in [environment] on [domain]"
    def next_server_name(app, environment, domain)
      next_name = TerraNova::NextServerName.call(
        app: app,
        environment: environment,
        domain: domain,
        options: options,
      )

      puts next_name
    end

    desc "create-dns-entry [name] [value] [type] [ttl] [domain]",
      "Create dns entry for [name] [value] of type [type] with a ttl of [ttl] on [domain]"
    def create_dns_entry(name, value, type, ttl, domain)
      dns_entry = TerraNova::CreateDnsEntry.call(
        name: name,
        value: value,
        type: type,
        ttl: ttl,
        domain: domain,
        options: options,
      )

      puts dns_entry
    end
  end
end
