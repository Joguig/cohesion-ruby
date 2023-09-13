require 'spec_helper'
require 'faraday'

describe Cohesion::API::AssociationV1 do
  let(:client) { double('Cohesion::Client') }
  let(:subject) { Cohesion::API::AssociationV1.new(client) }
  let(:from) { Cohesion::Entity.new(id: 1, kind: 'user') }
  let(:to) { Cohesion::Entity.new(id: 2, kind: 'user') }

  context '.create' do
    context 'is successful' do
      before do
        expect(client).to receive(:put)
          .with('/v1/associations/user/1/follow/user/2', {})
      end

      it 'creates an association' do
        association =
          subject.create(from: ['user', 1], kind: 'follow', to: ['user', 2])

        expect(association.from.id).to eq('1')
        expect(association.to.id).to eq('2')
        expect(association.kind).to eq('follow')
      end

      it 'accepts entities as params' do
        subject.create(from: from, kind: 'follow', to: to)
      end
    end

    context 'same entities' do
      it 'raises an error when to and from entities are the same' do
        expect do
          subject.create(from: ['user', 1], kind: 'follow', to: ['user', 1])
        end.to raise_error(ArgumentError)
      end
    end
  end

  context '.delete' do
    context 'is successful' do
      before do
        expect(client).to receive(:delete)
          .with('/v1/associations/user/1/follow/user/2')
      end

      it 'deletes an association' do
        subject.delete(from: ['user', 1], kind: 'follow', to: ['user', 2])
      end

      it 'accepts entities as params' do
        subject.delete(from: from, kind: 'follow', to: to)
      end
    end

    context 'same entities' do
      it 'raises an error when to and from entities are the same' do
        expect do
          subject.delete(from: ['user', 1], kind: 'follow', to: ['user', 1])
        end.to raise_error(ArgumentError)
      end
    end
  end

  context '.bulk_delete' do
    it 'deletes all associations' do
      expect(client).to receive(:delete).with('/v1/associations/user/1/follow/user')
      subject.bulk_delete(from: ['user', 1], kind: 'follow', bulk_kind: 'user')
    end
  end

  context '.update' do
    it 'sends data bag hash to client' do
      h = {
        a: 'b',
        c: 'd'
      }
      expect(client).to receive(:post)
        .with('/v1/associations/user/1/follow/user/2', h)
      subject.update(
        from: ['user', 1], kind: 'follow', to: ['user', 2], data: h
      )
    end
  end

  context '.batch_update' do
    it 'sends the data hash to the client' do
      data = {
        2 => { hidden: true },
        3 => { hidden: false, block_notifications: true }
      }
      expect(client).to receive(:patch)
        .with('/v1/associations/user/1/followed_by/user', data)
      subject.batch_update(
        from: ['user', 1], kind: 'followed_by', bulk_kind: 'user', data: data
      )
    end

    it 'should not make a patch request when data bag is empty' do
      expect(client).to_not receive(:patch)
        .with('/v1/associations/user/1/followed_by/user', {})
      expect do
        subject.batch_update(
          from: ['user', 1], kind: 'followed_by', bulk_kind: 'user', data: {}
        )
      end.to raise_error(ArgumentError)
    end
  end

  context '.bulk_update' do
    it 'sends the data hash to the client' do
      data = { hidden: false, block_notifications: true }
      expect(client).to receive(:post)
        .with('/v1/associations/user/1/followed_by/user', data)
      subject.bulk_update(
        from: ['user', 1], kind: 'followed_by', bulk_kind: 'user', data: data
      )
    end

    it 'should not make a patch request when data bag is empty' do
      expect(client).to_not receive(:post)
        .with('/v1/associations/user/1/followed_by/user', {})
      expect do
        subject.bulk_update(
          from: ['user', 1], kind: 'followed_by', bulk_kind: 'user', data: {}
        )
      end.to raise_error(ArgumentError, 'no associations to be updated')
    end
  end

  context '.fetch' do
    context 'is successful' do
      before do
        expect(client).to receive(:get)
          .with('/v1/associations/user/1/follow/user/2')
          .and_return(
            'from' => { 'id' => 1, 'kind' => 'user' },
            'kind' => 'follow',
            'to' => [
              {
                'target' => { 'id' => 2, 'kind' => 'user' },
                'data' => {},
                'time' => '2009-11-10T23:00:00Z'
              }
            ]
          )
      end

      it 'returns an association' do
        association =
          subject.fetch(from: ['user', 1], kind: 'follow', to: ['user', 2])
        expect(association.from.id).to eq(1)
        expect(association.to.id).to eq(2)
        expect(association.kind).to eq('follow')
      end

      it 'accepts entities as params' do
        subject.fetch(from: from, kind: 'follow', to: to)
      end
    end

    context 'same entities' do
      it 'returns nil when to and from entities are the same' do
        a = subject.fetch(from: ['user', 1], kind: 'follow', to: ['user', 1])
        expect(a).to be_nil
      end
    end

    context 'returns a 404' do
      before do
        expect(client).to receive(:get)
          .with('/v1/associations/user/1/follow/user/2')
          .and_raise(Faraday::Error::ResourceNotFound, '')
      end

      it 'returns nil when an association is not found' do
        a = subject.fetch(from: ['user', 1], kind: 'follow', to: ['user', 2])

        expect(a).to be_nil
      end
    end

    context 'optional param' do
      before do
        expect(client).to receive(:get)
          .with('/v1/associations/user/1/follow/user/2?priority=low')
          .and_return(
            'from' => { 'id' => 1, 'kind' => 'user' },
            'kind' => 'follow',
            'to' => [
              {
                'target' => { 'id' => 2, 'kind' => 'user' },
                'data' => {},
                'time' => '2009-11-10T23:00:00Z'
              }
            ]
          )
      end

      it 'priority is accepted' do
        subject.fetch(from: from, kind: 'follow', to: to, priority: 'low')
      end
    end
  end

  context '.list' do
    context 'is successful' do
      before do
        expect(client).to receive(:get)
          .with('/v1/associations/user/1/follow/user?sort=desc&limit=30')
          .and_return(
            'from' => { 'id' => 1, 'kind' => 'user' },
            'kind' => 'follow',
            'to' => [
              {
                'target' => { 'id' => 2, 'kind' => 'user' },
                'data' => {},
                'time' => '2009-11-10T23:00:00Z'
              },
              {
                'target' => { 'id' => 3, 'kind' => 'user' },
                'data' => { 'foo' => 'bar' },
                'time' => '2009-11-10T23:00:00Z'
              }
            ],
            'cursor' => '1234'
          )
      end

      it 'returns a list of assocations' do

        res = subject.list(from: ['user', 1], kind: 'follow', bulk_kind: 'user')

        expect(res[:results].size).to eq(2)

        res[:results].each do |a|
          expect(a.from.id).to eq(1)
          expect(a.from.kind).to eq('user')
          expect(a.kind).to eq('follow')
        end

        expect(res[:results][0].to.id).to eq(2)
        expect(res[:results][1].to.id).to eq(3)
        expect(res[:results][1].data).to eq('foo' => 'bar')
        expect(res[:cursor]).to eq('1234')
      end

      it 'accepts an entity as param' do
        subject.list(from: from, kind: 'follow', bulk_kind: 'user')
      end
    end

    context 'optional param' do
      before do
        expect(client).to receive(:get)
          .with('/v1/associations/user/1/follow/user'\
                '?sort=desc&limit=30&priority=test')
          .and_return(
            'from' => { 'id' => 1, 'kind' => 'user' },
            'kind' => 'follow',
            'to' => [
              {
                'target' => { 'id' => 2, 'kind' => 'user' },
                'data' => {},
                'time' => '2009-11-10T23:00:00Z'
              },
              {
                'target' => { 'id' => 3, 'kind' => 'user' },
                'data' => { 'foo' => 'bar' },
                'time' => '2009-11-10T23:00:00Z'
              }
            ]
          )
      end

      it 'priority is accepted' do
        subject.list(from: from, kind: 'follow', bulk_kind: 'user', priority: 'test')
      end
    end
  end

  context '.count' do
    before do
      expect(client).to receive(:get)
        .with('/v1/associations/user/1/follow/user/count')
        .and_return(
          'count' => 2
        )
    end

    it 'returns a count of associations' do
      result = subject.count(from: ['user', 1], kind: 'follow', bulk_kind: 'user')
      expect(result).to eq(2)
    end

    it 'accepts an entity as a param' do
      subject.count(from: from, kind: 'follow', bulk_kind: 'user')
    end
  end

  context '.batch' do
    it 'should have a body with the operations' do
      list = [
        {
          'from' => { 'id' => '1', 'kind' => 'user' },
          'kind' => 'follow',
          'to' => { 'id' => '2', 'kind' => 'user' },
          'data_bag' => { 'block_notifications' => true },
          'operation' => 'create'
        },
        {
          'from' => { 'id' => '1', 'kind' => 'user' },
          'kind' => 'follow',
          'to' => { 'id' => '2', 'kind' => 'user' },
          'operation' => 'delete'
        },
        {
          'from' => { 'id' => '1', 'kind' => 'user' },
          'kind' => 'follow',
          'data_bag' => { 'block_notifications' => true },
          'operation' => 'bulk_update'
        }
      ]

      e1 = Cohesion::Entity.new(id: '1', kind: 'user')
      e2 = Cohesion::Entity.new(id: '2', kind: 'user')
      kind = 'follow'
      data = { 'block_notifications' => true }
      time = DateTime.rfc3339('2014-02-25T06:35:35.993041-08:00')
      operations = {
        'create' => Cohesion::Association.new(
          from: e1, kind: kind, to: e2, data: data, time: time),
        'delete' => Cohesion::Association.new(
          from: e1, kind: kind, to: e2, data: nil, time: time),
        'bulk_update' => Cohesion::Association.new(
          from: e1, kind: kind, to: nil, data: data, time: time)
      }
      expect(client).to receive(:post)
        .with('/v1/associations/batch', list)
      subject.batch(operations: operations)
    end
  end
end
