require 'spec_helper'

describe Cohesion::Client do
  let(:subject) do
    Cohesion::Client.new do |config|
      config.endpoint = 'http://fake.test'
      config.source = 'foo/bar'
    end
  end

  context 'FetchAssociationCmd' do
    e1 = Cohesion::Entity.new(:id => 123, :kind => "user")
    e2 = Cohesion::Entity.new(:id => 456, :kind => "user")
    a1 = Cohesion::Association.new(:from => e1, :kind => "follows", :to => e2, :data => {}, :time => DateTime.rfc3339('2009-11-10T23:00:00Z'))

    it 'Fetches a nonexistant association & returns nil' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user/456').and_raise(Faraday::Error::ResourceNotFound, '').once

      result = Cohesion::FetchAssociationCmd.new(subject, ["user", 123], "follows", ["user", 456]).run
      expect(result).to eq(nil)
    end

    it 'Fetches an existing association & returns a processed association object' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user/456').and_return({
         'from' => {
             'kind' => 'user',
             'id' => 123
         },
         'to' => [
             {
                 'target' => {
                     'kind' => 'user',
                     'id' => 456
                 },
                 'data' => { },
                 'time' => '2009-11-10T23:00:00Z'
             }
         ],
         'kind' => 'follows'
      }).once

      result = Cohesion::FetchAssociationCmd.new(subject, ["user", 123], "follows", ["user", 456]).run
      expect(result).to_not eq(nil)
      expect(result).to eq(a1)
    end
  end

  context 'CountAssociationsCmd' do

    it 'Fetches a count of 0' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user/count').and_return({'count' => 0}).once

      result = Cohesion::CountAssociationsCmd.new(subject, ["user", 123], "follows", "user").run
      expect(result).to eq(0)
    end

    it 'Fetches a count of 3' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user/count').and_return({'count' => 3}).once

      result = Cohesion::CountAssociationsCmd.new(subject, ["user", 123], "follows", "user").run
      expect(result).to eq(3)
    end
  end

  context 'BatchUpdateAssociationsCmd' do

    it 'Successfully batches some updates' do
      updates = {'456' => {'updated' => true}, '789' => {'updated' => true}}
      expect(subject).to receive(:patch).with('/v1/associations/user/123/follows/user', updates).once

      result = Cohesion::BatchUpdateAssociationsCmd.new(subject, ["user", 123], "follows", "user", updates).execute
      expect(result).to eq(true)
    end

    it 'Fail to batch some updates' do
      updates = {'456' => {'updated' => true}, '789' => {'updated' => true}}
      expect(subject).to receive(:patch).with('/v1/associations/user/123/follows/user', updates).and_raise(Faraday::Error::ClientError, '').once

      result = Cohesion::BatchUpdateAssociationsCmd.new(subject, ["user", 123], "follows", "user", updates).execute
      expect(result).to eq(false)
    end
  end

  context 'BulkUpdateAssociationsCmd' do

    it 'Successfully batches some updates' do
      updates = {'data_bag' => {'update' => true}}
      expect(subject).to receive(:post).with('/v1/associations/user/123/follows/user', updates).once

      result = Cohesion::BulkUpdateAssociationsCmd.new(subject, ["user", 123], "follows", "user", updates).execute
      expect(result).to eq(true)
    end

    it 'Fail to batch some updates' do
      updates = {'456' => {'updated' => true}, '789' => {'updated' => true}}
      expect(subject).to receive(:post).with('/v1/associations/user/123/follows/user', updates).and_raise(Faraday::Error::ClientError, '').once

      result = Cohesion::BulkUpdateAssociationsCmd.new(subject, ["user", 123], "follows", "user", updates).execute
      expect(result).to eq(false)
    end
  end

  context 'CreateAssociationCmd' do

    it 'Successfully create an association' do
      time = DateTime.now()

      e1 = Cohesion::Entity.new(id: "123", kind: "user")
      e2 = Cohesion::Entity.new(id: "456", kind: "user")
      a1 = Cohesion::Association.new(from: e1, to: e2, kind: "follows", data: {'new' => true}, time: time)

      expect(DateTime).to receive(:now).and_return(time)
      expect(subject).to receive(:put).with('/v1/associations/user/123/follows/user/456', {'new' => true}).once

      result = Cohesion::CreateAssociationCmd.new(subject, ["user", 123], "follows", ["user", 456], {'new' => true}).run
      expect(result).to eq(a1)
    end

    it 'Fails to create an association' do
      expect(subject).to receive(:put).with('/v1/associations/user/123/follows/user/456', {'new' => true}).and_raise(Faraday::Error::ClientError, '').once

      result = Cohesion::CreateAssociationCmd.new(subject, ["user", 123], "follows", ["user", 456], {'new' => true}).execute
      expect(result).to eq(nil)
    end
  end

  context 'DeleteAssociationCmd' do

    it 'Successfully deletes an association' do
      expect(subject).to receive(:delete).with('/v1/associations/user/123/follows/user/456').once

      result = Cohesion::DeleteAssociationCmd.new(subject, ["user", 123], "follows", ["user", 456]).execute
      expect(result).to eq(true)
    end

    it 'Fails to delete an association' do
      expect(subject).to receive(:delete).with('/v1/associations/user/123/follows/user/456').and_raise(Faraday::Error::ClientError, '').once

      result = Cohesion::DeleteAssociationCmd.new(subject, ["user", 123], "follows", ["user", 456]).execute
      expect(result).to eq(false)
    end
  end

  context 'BulkDeleteAssociationsCmd' do

    it 'Successfully deletes associations' do
      expect(subject).to receive(:delete).with('/v1/associations/user/123/follows/user').once

      result = Cohesion::BulkDeleteAssociationsCmd.new(subject, ["user", 123], "follows", "user").execute
      expect(result).to eq(true)
    end

    it 'Fail to delete associations' do
      expect(subject).to receive(:delete).with('/v1/associations/user/123/follows/user').and_raise(Faraday::Error::ClientError, '').once

      result = Cohesion::BulkDeleteAssociationsCmd.new(subject, ["user", 123], "follows", "user").execute
      expect(result).to eq(false)
    end
  end

  context 'ListAssociationCmd' do
    e1 = Cohesion::Entity.new(:id => '123', :kind => "user")
    e2 = Cohesion::Entity.new(:id => '456', :kind => "user")
    e3 = Cohesion::Entity.new(:id => '789', :kind => "user")
    e4 = Cohesion::Entity.new(:id => '987', :kind => "user")
    a1 = Cohesion::Association.new(:from => e1, :kind => "follows", :to => e2, :data => {}, :time => DateTime.rfc3339('2009-11-10T23:00:00Z'))
    a2 = Cohesion::Association.new(:from => e1, :kind => "follows", :to => e3, :data => {'updated' => true}, :time => DateTime.rfc3339('2009-11-10T23:00:00Z'))
    a3 = Cohesion::Association.new(:from => e1, :kind => "follows", :to => e4, :data => {}, :time => DateTime.rfc3339('2009-11-10T23:00:00Z'))

    it 'Fetches an empty list of associations' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user?sort=desc&limit=3').and_return({
          'from' => {
              'kind' => 'user',
              'id' => '123'
          },
          'to' => [
          ],
          'kind' => 'follows'
       }).once

      result = Cohesion::ListAssociationsCmd.new(subject, ["user", 123], "follows", "user", limit:3).run
      expect(result).to_not eq(nil)
      expect(result[:cursor]).to_not eq(nil)
      expect(result[:cursor]).to be_empty()
      expect(result[:results]).to_not eq(nil)
      expect(result[:results]).to be_empty()
    end

    it 'Fetches a list of 3 associations with no cursor' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user?sort=desc&limit=3').and_return({
          'from' => {
              'kind' => 'user',
              'id' => '123'
          },
          'to' => [
              {
                  'target' => {
                      'kind' => 'user',
                      'id' => '456'
                  },
                  'data' => {},
                  'time' => '2009-11-10T23:00:00Z'
              },
              {
                  'target' => {
                      'kind' => 'user',
                      'id' => '789'
                  },
                  'data' => {'updated' => true},
                  'time' => '2009-11-10T23:00:00Z'
              },
              {
                  'target' => {
                      'kind' => 'user',
                      'id' => '987'
                  },
                  'data' => {},
                  'time' => '2009-11-10T23:00:00Z'
              }
          ],
          'kind' => 'follows'
      }).once

      result = Cohesion::ListAssociationsCmd.new(subject, ["user", 123], "follows", "user", limit:3).run
      expect(result).to_not eq(nil)
      expect(result[:cursor]).to_not eq(nil)
      expect(result[:cursor]).to be_empty()
      expect(result[:results]).to_not eq(nil)
      expect(result[:results].size).to eq(3)
      expect(result[:results][0]).to eq(a1)
      expect(result[:results][1]).to eq(a2)
      expect(result[:results][2]).to eq(a3)
    end

    it 'Fetches a list of 3 associations with cursor' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user?sort=desc&limit=3').and_return({
          'from' => {
              'kind' => 'user',
              'id' => '123'
          },
          'to' => [
              {
                  'target' => {
                      'kind' => 'user',
                      'id' => '456'
                  },
                  'data' => {},
                  'time' => '2009-11-10T23:00:00Z'
              },
              {
                  'target' => {
                      'kind' => 'user',
                      'id' => '789'
                  },
                  'data' => {'updated' => true},
                  'time' => '2009-11-10T23:00:00Z'
              },
              {
                  'target' => {
                      'kind' => 'user',
                      'id' => '987'
                  },
                  'data' => {},
                  'time' => '2009-11-10T23:00:00Z'
              }
          ],
          'kind' => 'follows',
          'cursor' => '1234567890'
      }).once

      result = Cohesion::ListAssociationsCmd.new(subject, ["user", 123], "follows", "user", limit:3).run
      expect(result).to_not eq(nil)
      expect(result[:cursor]).to eq('1234567890')
      expect(result[:results]).to_not eq(nil)
      expect(result[:results].size).to eq(3)
      expect(result[:results][0]).to eq(a1)
      expect(result[:results][1]).to eq(a2)
      expect(result[:results][2]).to eq(a3)
    end

    it 'Fetches a list of 3 associations with a cursor, request contains cursor' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user?sort=desc&limit=3&cursor=1000').and_return({
       'from' => {
           'kind' => 'user',
           'id' => '123'
       },
       'to' => [
           {
               'target' => {
                   'kind' => 'user',
                   'id' => '456'
               },
               'data' => {},
               'time' => '2009-11-10T23:00:00Z'
           },
           {
               'target' => {
                   'kind' => 'user',
                   'id' => '789'
               },
               'data' => {'updated' => true},
               'time' => '2009-11-10T23:00:00Z'
           },
           {
               'target' => {
                   'kind' => 'user',
                   'id' => '987'
               },
               'data' => {},
               'time' => '2009-11-10T23:00:00Z'
           }
       ],
       'kind' => 'follows',
       'cursor' => '1234567890'
      }).once

      result = Cohesion::ListAssociationsCmd.new(subject, ["user", 123], "follows", "user", limit:3, cursor:'1000').run
      expect(result).to_not eq(nil)
      expect(result[:cursor]).to eq('1234567890')
      expect(result[:results]).to_not eq(nil)
      expect(result[:results].size).to eq(3)
      expect(result[:results][0]).to eq(a1)
      expect(result[:results][1]).to eq(a2)
      expect(result[:results][2]).to eq(a3)
    end
  end

  context 'UpdateAssociationCmd' do
    # find_follow stubs
    e1 = Cohesion::Entity.new(:id => '123', :kind => "user")
    e2 = Cohesion::Entity.new(:id => '456', :kind => "user")
    a1 = Cohesion::Association.new(:from => e1, :kind => "follows", :to => e2, :data => {'value' => 'val', 'update' => true}, :time => DateTime.rfc3339('2009-11-10T23:00:00Z'))
    a2 = Cohesion::Association.new(:from => e1, :kind => "hidden_follows", :to => e2, :data => {'update' => true}, :time => DateTime.rfc3339('2009-11-10T23:00:00Z'))

    it 'Fetches a nonexistant association & does not attempt to update' do
      expect(subject).to receive(:get).with('/v1/associations/user/456/follows/user/123').and_raise(Faraday::Error::ResourceNotFound, '').once

      result = Cohesion::UpdateAssociationsCmd.new(subject, ["user", 456], "follows", ["user", 123], {'update' => true}).run
      expect(result).to eq(nil)
    end

    it 'Fetches an existing association and does attempt to update databag' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user/456').and_return({
         'from' => {
             'kind' => 'user',
             'id' => '123'
         },
         'to' => [
             {
                 'target' => {
                     'kind' => 'user',
                     'id' => '456'
                 },
                 'data' => {
                     'update' => false,
                     'value' => 'val'
                 },
                 'time' => '2009-11-10T23:00:00Z'
             }
         ],
         'kind' => 'follows'
      }).once

      expect(subject).to receive(:post).with('/v1/associations/user/123/follows/user/456', {
          'data_bag' => {
              'update' => true
          }
      }).once

      result = Cohesion::UpdateAssociationsCmd.new(subject, ["user", 123], "follows", ["user", 456], {'data_bag' => {'update' => true}}).run
      expect(result).not_to eq(nil)
      expect(result).to eq(a1)
    end

    it 'Fetches an existing association and does attempt to update kind & databag with no necessary merge' do
      expect(subject).to receive(:get).with('/v1/associations/user/123/follows/user/456').and_return({
         'from' => {
             'kind' => 'user',
             'id' => '123'
         },
         'to' => [
             {
                 'target' => {
                     'kind' => 'user',
                     'id' => '456'
                 },
                 'data' => {},
                 'time' => '2009-11-10T23:00:00Z'
             }
         ],
         'kind' => 'follows'
      }).once

      expect(subject).to receive(:post).with('/v1/associations/user/123/follows/user/456', {
          'data_bag' => {
              'update' => true
          },
          'new_assoc_kind' => 'hidden_follows'
      }).once

      result = Cohesion::UpdateAssociationsCmd.new(subject, ["user", 123], "follows", ["user", 456], {'data_bag' => {'update' => true}, 'new_assoc_kind' => 'hidden_follows'}).run
      expect(result).not_to eq(nil)
      expect(result).to eq(a2)
    end
  end
end
