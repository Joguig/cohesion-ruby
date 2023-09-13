require 'hystrix'


module Cohesion

  class CohesionCmd < Hystrix::Command
    attr_accessor :client

    timeout_in_milliseconds 500

    circuit_breaker(
        min_requests: 5
    )

    def initialize(client)
      self.client = client
      super()
    end
  end

  class FetchAssociationCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :to, :priority

    def initialize(client, from, assoc_kind, to, priority: "")
      super client

      self.from = from
      self.assoc_kind = assoc_kind
      self.to = to
      self.priority = priority
    end

    def run
      self.client.associations.fetch(from: self.from, kind: assoc_kind, to: self.to, priority: self.priority)
    end

    def fallback(error)
      nil
    end
  end

  class ListAssociationsCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :bulk_kind, :bulk_kind, :limit, :offset, :priority, :sort, :cursor

    def initialize(client, from, assoc_kind, bulk_kind, limit: 30, offset: 0, priority: "", sort: "desc", cursor: "")
      super client
      self.from = from
      self.assoc_kind = assoc_kind
      self.bulk_kind = bulk_kind
      self.limit = limit
      self.offset = offset
      self.priority = priority
      if sort == nil || sort.size == 0
        sort = "desc"
      end
      self.sort = sort
      self.cursor = cursor
    end

    def run
      self.client.associations.list(
          from: self.from,
          kind: self.assoc_kind,
          bulk_kind: self.bulk_kind,
          limit: self.limit,
          offset: self.offset,
          priority: self.priority,
          sort: self.sort,
          cursor: self.cursor
      )
    end

    def fallback(error)
      {:cursor => '', :results => []}
    end
  end

  class CreateAssociationCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :to, :data

    def initialize(client, from, assoc_kind, to, data={})
      super client

      self.from = from
      self.assoc_kind = assoc_kind
      self.to = to
      self.data = data
    end

    def run
      self.client.associations.create(from: self.from, kind: self.assoc_kind, to: self.to, data: self.data)
    end

    def fallback(error)
      nil
    end
  end

  class DeleteAssociationCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :to

    def initialize(client, from, assoc_kind, to)
      super client

      self.from = from
      self.assoc_kind = assoc_kind
      self.to = to
    end

    def run
      self.client.associations.delete(from: self.from, kind: self.assoc_kind, to: self.to)
    end

    def fallback(error)
      false
    end
  end

  class BulkDeleteAssociationsCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :bulk_kind

    timeout_in_milliseconds 2000

    def initialize(client, from, assoc_kind, bulk_kind)
      super client

      self.from = from
      self.assoc_kind = assoc_kind
      self.bulk_kind = bulk_kind
    end

    def run
      self.client.associations.bulk_delete(from: self.from, kind: self.assoc_kind, bulk_kind: self.bulk_kind)
    end

    def fallback(error)
      false
    end
  end

  class UpdateAssociationsCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :to, :data

    def initialize(client, from, assoc_kind, to, data = {})
      super client

      self.from = from
      self.to = to
      self.assoc_kind = assoc_kind
      self.data = data
    end

    def run
      a = self.client.associations.fetch(from: self.from, kind: self.assoc_kind, to: self.to)

      if a == nil
        return nil
      end

      self.client.associations.update(from: self.from, kind: self.assoc_kind, to: self.to, data: self.data)

      # update can either change the association type or the data bag.
      a.data = a.data.merge(self.data["data_bag"]) if self.data.has_key?("data_bag")
      a.kind = self.data["new_assoc_kind"] if self.data.has_key?("new_assoc_kind")

      a
    end

    def fallback(error)
      nil
    end
  end

  class MultiUpdateCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :bulk_kind, :data

    def initialize(client, from, assoc_kind, bulk_kind, data)
      super client

      self.from = from
      self.bulk_kind = bulk_kind
      self.assoc_kind = assoc_kind
      self.data = data
    end

    def fallback(error)
      false
    end
  end

  class BatchUpdateAssociationsCmd < MultiUpdateCmd
    def run
      self.client.associations.batch_update(from: self.from, kind: self.assoc_kind, bulk_kind: self.bulk_kind, data: self.data)
    end
  end

  class BulkUpdateAssociationsCmd < MultiUpdateCmd
    def run
      self.client.associations.bulk_update(from: self.from, kind: self.assoc_kind, bulk_kind: self.bulk_kind, data: self.data)
    end
  end

  class CountAssociationsCmd < CohesionCmd
    attr_accessor :from, :assoc_kind, :bulk_kind

    def initialize(client, from, assoc_kind, bulk_kind)
      super client
      self.from = from
      self.assoc_kind = assoc_kind
      self.bulk_kind = bulk_kind
    end

    def run
      self.client.associations.count(from: self.from, kind: self.assoc_kind, bulk_kind: self.bulk_kind)
    end

    def fallback(error)
      0
    end
  end
end