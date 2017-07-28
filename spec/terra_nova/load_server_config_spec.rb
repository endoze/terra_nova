require 'spec_helper'

RSpec.describe TerraNova::LoadServerConfig do
  let(:file) {
    file = double("file")
    allow(file).to receive(:read).and_return(<<-EOF
      test:
        apps:
          banana:
            ami_id: 'ami-4b133c5d'
            tags:
              Name: <%= next_server_name %>
    EOF
    )

    file
  }

  let(:locals) { {next_server_name: 'test-banana-001'} }

  describe '#initialize' do
    it 'loads data from the specified yaml' do
      expect(file).to receive(:read)

      config = TerraNova::LoadServerConfig.new(
        file: file,
        environment: 'test',
        app: 'banana',
        locals: locals,
      )
    end
  end

  describe '#[]' do
    context 'when the key exists' do
      it 'returns the value from the configuration read from disk' do
        config = TerraNova::LoadServerConfig.new(
          file: file,
          environment: 'test',
          app: 'banana',
          locals: locals,
        )

        expect(config[:ami_id]).to eq('ami-4b133c5d')
      end

      it 'allows access via string or symbol keys' do
        config = TerraNova::LoadServerConfig.new(
          file: file,
          environment: 'test',
          app: 'banana',
          locals: locals,
        )

        expect(config[:ami_id]).to eq('ami-4b133c5d')
        expect(config['ami_id']).to eq('ami-4b133c5d')
      end

      it 'replaces erb tags with values' do
        config = TerraNova::LoadServerConfig.new(
          file: file,
          environment: 'test',
          app: 'banana',
          locals: locals,
        )

        expect(config[:tags][:Name]).to eq('test-banana-001')
      end
    end

    context 'when the key does not exist' do
      it 'returns nil' do
        config = TerraNova::LoadServerConfig.new(
          file: file,
          environment: 'test',
          app: 'banana',
          locals: locals,
        )

        expect(config[:non_existant]).to be_nil
      end
    end
  end
end
