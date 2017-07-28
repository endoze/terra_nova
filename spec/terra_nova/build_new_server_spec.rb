require 'spec_helper'

class MockLoadServerConfiguration < TerraNova::LoadServerConfig
  def set_subnet_id(subnet_id)
    @configuration["subnet_id"] = subnet_id
  end

private
  def read_file
    @configuration ||= HashWithIndifferentAccess.new({
      ami_id: 'ami-4b133c5d',
      availability_zone: 'us-east-1e',
      block_device_mapping: {
        device_name: "/dev/sda1",
        volume_size: 100,
        delete_on_termination: true,
      },
      cloudwatch: true,
      disable_api_termination: true,
      ebs_optimized: true,
      instance_type: "c4.xlarge",
      key_name: "test-key-pair",
      region: "us-east-1",
      security_group_id: "",
      subnet_id: "",
      tags: [
        App: "test-apple",
        Name: "test-apple-001",
        Monitored: false,
        Env: "test",
      ],
      provision_script: "ansible-playbook -i 'apple.example.com,' -s -u ubuntu apple_app.yml"
    })
  end
end

RSpec.describe TerraNova::BuildNewServer do
  describe '#call' do
    before(:all) do
      ec2 = Fog::Compute::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
      ec2.create_key_pair('test-key-pair')
      ec2.create_vpc('10.0.0.0/16')
      vpc_id = ec2.vpcs.first.id
      ec2.create_subnet(vpc_id, '10.0.0.0/16')
      subnet_id = ec2.subnets.first.subnet_id
      @mock_server_config = MockLoadServerConfiguration.new(app: 'apple', environment: 'test')
      @mock_server_config.set_subnet_id(subnet_id)
    end

    after(:all) do
      ec2 = Fog::Compute::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
      ec2.key_pairs.first.destroy
      ec2.subnets.first.destroy
      ec2.vpcs.first.destroy
    end

    context 'when the domain is registered with aws' do
      after(:all) do
        ec2 = Fog::Compute::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
        ec2.servers.first.destroy
      end

      it 'creates a new server' do
        allow(TerraNova::LoadServerConfig).to receive(:new).and_return(@mock_server_config)
        ec2 = Fog::Compute::AWS.new(aws_access_key_id: '', aws_secret_access_key: '')
        instance_attributes = TerraNova::BuildNewServer.call(
          app: 'apple',
          environment: 'test',
          domain: 'example.com.',
          options: {'aws_key' => '', 'aws_secret' => '', monitored: false},
        )

        expect(ec2.servers.count).to eq(1)
        expect(instance_attributes[:instance_id]).not_to be_nil
        expect(instance_attributes[:public_ip]).not_to be_nil
        expect(instance_attributes[:dns_name]).not_to be_nil
      end
    end
  end
end
