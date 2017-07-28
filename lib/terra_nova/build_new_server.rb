module TerraNova
  class BuildNewServer
    attr_accessor :app,
                  :environment,
                  :instance_attributes,
                  :options,
                  :monitored,
                  :target_zone_domain,
                  :configuration

    def initialize(app:, environment:, domain:, options:)
      @app = app
      @environment = environment
      @monitored = options[:monitored]
      @target_zone_domain = domain
      @options = HashWithIndifferentAccess.new(options.reject { |key, _| key == 'monitored' })
    end

    def self.call(app:, environment:, domain:, options:)
      self.new(
        app: app,
        environment: environment,
        domain: domain,
        options: options,
      ).call
    end

    def call
      load_configuration

      create_new_instance
      add_tags
      create_route53_entry

      instance_attributes
    end

  private

    def load_configuration
      @configuration = TerraNova::LoadServerConfig.new(
        environment: environment,
        app: app,
        locals: {
          monitored: monitored,
          domain: target_zone_domain,
          next_server_name: next_instance_name,
        })
    end

    def ec2
      @_ec2 ||= Fog::Compute::AWS.new(
        aws_access_key_id: @options[:aws_key],
        aws_secret_access_key: @options[:aws_secret],
        region: @configuration[:region],
      )
    end

    def create_new_instance
      response = ec2.run_instances(
        @configuration[:ami_id],
        1,
        1,
        "Placement.AvailabilityZone" => @configuration[:availability_zone],
        "BlockDeviceMapping"         => [
          "DeviceName"                 => @configuration[:block_device_mapping][:device_name],
          "Ebs.VolumeSize"             => @configuration[:block_device_mapping][:volume_size],
          "Ebs.DeleteOnTermination"    => @configuration[:block_device_mapping][:delete_on_termination],
        ],
        "Monitoring.Enabled"         => @configuration[:cloudwatch],
        "DisableApiTermination"      => @configuration[:disable_api_termination],
        "EbsOptimized"               => @configuration[:ebs_optimized],
        "SecurityGroupId"            => @configuration[:security_group_id],
        "InstanceType"               => @configuration[:instance_type],
        "KeyName"                    => @configuration[:key_name],
        "SubnetId"                   => @configuration[:subnet_id],
      )

      instance_id = response.body["instancesSet"].first["instanceId"]
      instance = ec2.servers.all.get(instance_id)

      instance.wait_for { ready? }

      instance_attributes = {
        instance_id: instance_id,
        public_ip: instance.public_ip_address,
        dns_name: instance.dns_name,
        provision_script: @configuration[:provision_script],
      }

      @instance_attributes = instance_attributes
    end

    def add_tags
      response = ec2.create_tags(instance_attributes[:instance_id], tags_for_instance)

      response.data
    end

    def tags_for_instance
      @configuration['tags']
    end

    def next_instance_name
      @_next_instance_name ||= TerraNova::NextServerName.call(
        app: app,
        environment: environment,
        domain: @target_zone_domain,
        options: options,
      )
    end

    def create_route53_entry
      @_create_route53_entry ||= TerraNova::CreateDnsEntry.call(
        name: "#{next_instance_name}.#{@target_zone_domain}",
        type: 'CNAME',
        value: instance_attributes[:dns_name],
        ttl: 60,
        domain: @target_zone_domain,
        options: options,
      )
    end
  end
end
