require 'spec_helper'

RSpec.describe TerraNova::NextServerName do
  describe '#call' do
    context 'when the domain is registered with aws' do
      it 'returns a server name formatted as <env>-<app>-<number>' do
        next_name = TerraNova::NextServerName.call(
          app: 'banana',
          environment: 'test',
          domain: 'example.com.',
          options: {'aws_key' => '', 'aws_secret' => ''},
        )

        expect(next_name).to eq('test-banana-001')
      end

      context 'when an app already exists' do
        before(:all) do
          dns = Fog::DNS::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
          zone = dns.zones.first
          zone.records.create(name: 'test-banana-001.example.com.', type: 'CNAME', value: 'example.com')
        end

        after(:all) do
          dns = Fog::DNS::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
          zone = dns.zones.first
          record = zone.records.first
          record.destroy
        end

        it 'returns a server name with the next number' do
          next_name = TerraNova::NextServerName.call(
            app: 'banana',
            environment: 'test',
            domain: 'example.com.',
            options: {'aws_key' => '', 'aws_secret' => ''},
          )

          expect(next_name).to eq('test-banana-002')
        end
      end
    end

    context 'when the domain is not registered with aws' do
      it 'raises a TerraNova::Exceptions::InvalidDomain' do
        expect {
          TerraNova::NextServerName.call(
            app: 'banana',
            environment: 'prod',
            domain: 'not-registered.com.',
            options: {'aws_key' => '', 'aws_secret' => ''},
          )
        }.to raise_error TerraNova::Exceptions::InvalidDomain
      end
    end
  end
end
