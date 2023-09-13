require 'spec_helper'

describe Cohesion::Client do
  let(:subject) do
    Cohesion::Client.new do |config|
      config.endpoint = 'http://fake.test'
      config.source = 'foo/bar'
    end
  end

  context '.new' do
    it 'allows block configuration during construction' do
      expect(subject.version).to eq(1)
      expect(subject.endpoint).to eq('http://fake.test')
    end

    it 'creates the appropriate association api version' do
      expect(subject.associations.class).to eq(Cohesion::API::AssociationV1)
    end

    it 'allows configuring calling project' do
      expect(subject.source).to eq('code.justin.tv/foo/bar')
    end
  end

  context '.get' do
    it 'json decodes responses' do
      stub_request(:get, 'http://fake.test/foo')
        .to_return(body: '{"key": "value"}')
      response = subject.get('/foo')

      expect(response['key']).to eq('value')
    end

    it 'raises errors' do
      stub_request(:get, 'http://fake.test/foo').to_return(status: 400)

      expect { subject.get('/foo') }.to raise_error Faraday::ClientError
    end

    it 'sets source header' do
      stub_request(:get, 'http://fake.test/foo')
        .with(headers: { 'Twitch-Repository' => 'code.justin.tv/foo/bar' })
      subject.get('/foo')
    end
  end

  context '.put' do
    it 'sends json request bodies' do
      stub_request(:put, 'http://fake.test/foo')
        .with(body: { 'a' => 'b', 'c' => 'd' })

      subject.put('/foo', 'a' => 'b', 'c' => 'd')
    end

    it 'sends valid empty body' do
      stub_request(:put, 'http://fake.test/foo').with(body: '{}')

      subject.put('/foo', {})
    end
  end

  context '.post' do
    it 'sends json request bodies' do
      stub_request(:post, 'http://fake.test/foo')
        .with(body: { 'a' => 'b', 'c' => 'd' })

      subject.post('/foo', 'a' => 'b', 'c' => 'd')
    end
  end

  context '.delete' do
    it 'makes a DELETE request' do
      stub_request(:delete, 'http://fake.test/foo')
      subject.delete('/foo')
    end
  end
end
