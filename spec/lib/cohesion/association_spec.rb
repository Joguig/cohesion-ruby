require 'spec_helper'

describe Cohesion::Association do
  let(:response) do
    {
      'from' => { 'id' => 1, 'kind' => 'user' },
      'kind' => 'follow',
      'to' => [
        {
          'target' => { 'id' => 2, 'kind' => 'user' },
          'data' => {},
          'time' => '2014-02-25T06:35:35.993041-08:00'
        }
      ]
    }
  end
  context '.from_hash' do
    let(:subject) { Cohesion::Association.from_hash(response) }

    it 'parses times as RFC3339' do
      expect(subject.time.year).to eq(2014)
      expect(subject.time.month).to eq(2)
      expect(subject.time.day).to eq(25)
      expect(subject.time.hour).to eq(6)
      expect(subject.time.minute).to eq(35)
      expect(subject.time.second).to eq(35)
      expect(subject.time.offset).to eq(Rational(-8, 24))
    end
  end

  context '.list_from_hash' do
    let(:subject) { Cohesion::Association.list_from_hash(response) }

    it 'parses times as RFC3339' do
      expect(subject[0].time.year).to eq(2014)
      expect(subject[0].time.month).to eq(2)
      expect(subject[0].time.day).to eq(25)
      expect(subject[0].time.hour).to eq(6)
      expect(subject[0].time.minute).to eq(35)
      expect(subject[0].time.second).to eq(35)
      expect(subject[0].time.offset).to eq(Rational(-8, 24))
    end
  end

  context '.to_hash' do
    before do
      @e1 = Cohesion::Entity.new(id: '1', kind: 'user')
      @e2 = Cohesion::Entity.new(id: '2', kind: 'user')
      @kind = 'follow'
      @data = { 'block_notifications' => true }
      @time = DateTime.rfc3339('2014-02-25T06:35:35.993041-08:00')
    end

    it 'creates a hash without a to key' do
      a = Cohesion::Association.new(
        from: @e1, kind: @kind, to: nil, data: @data, time: @time)
      h = a.to_hash

      expect(h.key?('to')).to be false
      expect(h.key?('data_bag')).to be true
      expect(h.key?('from')).to be true
      expect(h.key?('kind')).to be true
    end

    it 'creates a hash without a data key' do
      a = Cohesion::Association.new(
        from: @e1, kind: @kind, to: @e2, data: nil, time: @time)
      h = a.to_hash

      expect(h.key?('data_bag')).to be false
      expect(h.key?('to')).to be true
      expect(h.key?('from')).to be true
      expect(h.key?('kind')).to be true
    end
  end
end
