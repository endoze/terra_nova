require 'spec_helper'

RSpec.describe TerraNova::CreateDnsEntry do
  describe '#call' do
    context 'when the domain is registered with aws' do
      after(:each) do
        dns = Fog::DNS::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
        zone = dns.zones.first
        record = zone.records.first
        record.destroy
      end

      it 'returns a 200 in the response from creating the record' do
        response = TerraNova::CreateDnsEntry.call(
          name: 'prod-banana-001.example.com.',
          type: 'CNAME',
          value: 'example.com.',
          ttl: 60,
          domain: 'example.com.',
          options: {'aws_key' => '', 'aws_secret' => ''},
        )

        expect(response[:status]).to eq(200)
      end
    end

    context 'when the domain is not registered with aws' do
      it 'raises a TerraNova::Exceptions::InvalidDomain' do
        expect {
          TerraNova::CreateDnsEntry.call(
            name: 'prod-banana-001.not-registered.com.',
            type: 'CNAME',
            value: 'not-registered.com.',
            ttl: 60,
            domain: 'not-registered.com.',
            options: {'aws_key' => '', 'aws_secret' => ''},
          )
        }.to raise_error TerraNova::Exceptions::InvalidDomain
      end
    end
  end
end
