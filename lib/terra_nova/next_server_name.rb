module TerraNova
  class NextServerName
    attr_accessor :app, :environment, :options, :target_zone_domain

    def initialize(app:, environment:, domain:, options:)
      @app = app
      @environment = environment
      @target_zone_domain = domain
      @options = HashWithIndifferentAccess.new(options)
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
      next_name
    end

  private

    def next_name
      @_next_name ||= server_name_string(next_number)
    end

    def server_name_string(number)
      "#{environment}-#{app}-#{number}"
    end

    def next_number
      @_next_number ||= "%03d" % (current_number.to_i + 1)
    end

    def current_number
      @_current_number ||= begin
        match_data = app_names.sort.last&.match(/(?<server_number>\d{3})/)
        match_data&.[](:server_number) || '000'
     end
    end

    def app_names
      @_app_names ||= target_zone.records.all!.select do |r|
        r.name =~ /#{environment}-#{app}/
      end.map(&:name)
    end

    def target_zone
      target_zone = dns.zones.find { |z| z.domain == @target_zone_domain }

      return target_zone if target_zone

      raise TerraNova::Exceptions::InvalidDomain, @target_zone_domain
    end

    def dns
      @_dns ||= Fog::DNS::AWS.new(
        aws_access_key_id: @options[:aws_key],
        aws_secret_access_key: @options[:aws_secret],
      )
    end
  end
end
