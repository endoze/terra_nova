require 'erb'

module TerraNova
  class LoadServerConfig
    attr_accessor :configuration, :locals, :app
    attr_reader :file

    def initialize(file: File.new('infrastructure.yml', 'r'), environment:, app:, locals: {})
      @file = file
      @locals = locals.merge(environment: environment, app: app)
      @environment = environment
      @app = app
      read_file
    end

    def [](key)
      configuration&.[](key.to_sym)
    end

  private

    def read_file
      data = @file.read

      read_yaml_and_parse_erb(data)
    end

    def read_yaml_and_parse_erb(data)
      context = TOPLEVEL_BINDING.dup

      locals.each_pair do |key, value|
        context.local_variable_set(key, value)
      end

      yaml_data = YAML.load(ERB.new(data).result(context))

      indifferent_hash = HashWithIndifferentAccess.new(yaml_data)[@environment][:apps][@app]

      @configuration = indifferent_hash
    end
  end
end
