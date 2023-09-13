module Cohesion
  # Entity is of type `kind` (e.g. user) with an `id`
  class Entity
    attr_accessor :id, :kind

    def initialize(id:, kind:)
      self.id = id
      self.kind = kind
    end

    def self.from_hash(h)
      new(id: h['id'], kind: h['kind'])
    end

    def to_hash
      { 'id' => id, 'kind' => kind }
    end

    def ==(compare_entity)
      if !compare_entity.is_a?(Entity)
        return false
      end

      return self.id == compare_entity.id && self.kind == compare_entity.kind
    end
  end
end
