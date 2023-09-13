module Cohesion
  # Association describes the `kind` of relation between a `from` and `to entity
  # includes a data bag and created time
  class Association
    attr_accessor :from, :kind, :to, :data, :time

    def initialize(from:, kind:, to:, data:, time:)
      self.from = from
      self.kind = kind
      self.to = to
      self.data = data
      self.time = time
    end

    def ==(compare_assoc)
      if !compare_assoc.is_a?(Association)
        return false
      end

      return self.from == compare_assoc.from && self.kind == compare_assoc.kind && self.to == compare_assoc.to &&
          self.data == compare_assoc.data && self.time == compare_assoc.time
    end

    def self.from_hash(h)
      to = h['to'][0]
      from = h['from']
      from_entity = Entity.from_hash(from)
      to_entity = Entity.from_hash(to['target'])

      new(
        from: from_entity, kind: h['kind'],
        to: to_entity, data: to['data'],
        time: DateTime.rfc3339(to['time'])
      )
    end

    def self.list_from_hash(h)
      from_entity = Entity.from_hash(h['from'])

      list = []

      h['to'].each do |e|
        to_entity = Entity.from_hash(e['target'])

        # create a new association and append it to the list
        list << new(
          from: from_entity, kind: h['kind'], to: to_entity,
          data: e['data'], time: DateTime.rfc3339(e['time'])
        )
      end
      list
    end

    def to_hash
      h = {}
      h['from'] = from.to_hash
      h['kind'] = kind

      h['to'] = to.to_hash if to
      h['data_bag'] = data if data
      h
    end
  end
end
