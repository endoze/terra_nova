module TerraNova
  class CreateDnsEntry
    attr_accessor :name, :type, :value, :ttl, :target_zone_domain, :options

    def initialize(name:, type:, value:, ttl:, domain:, options:)
      @name = name
      @type = type
      @value = value
      @ttl = ttl
      @target_zone_domain = domain
      @options = HashWithIndifferentAccess.new(options)
    end

    def self.call(name:, type:, value:, ttl:, domain:, options:)
      self.new(
        name: name,
        type: type,
        value: value,
        ttl: ttl,
        domain: domain,
        options: options
      ).call
    end

    def call
      create_new_record
    end

  private

    def dns
      @_dns ||= Fog::DNS::AWS.new(
        aws_access_key_id: @options['aws_key'],
        aws_secret_access_key: @options['aws_secret'],
      )
    end

    def create_new_record
      response = dns.change_resource_record_sets(target_zone.id, change_batch)

      response.data
    end

    def target_zone
      target_zone = dns.zones.find { |zone| zone.domain == @target_zone_domain }

      return target_zone if target_zone

      raise TerraNova::Exceptions::InvalidDomain, @target_zone_domain
    end

    def change_batch
      [
        {
          action: 'CREATE',
          type: type,
          name: name,
          ttl: ttl,
          resource_records: [value],
        }
      ]
    end
  end
end
