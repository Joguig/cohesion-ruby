module Cohesion
  module API
    # AssociationV1 is the v1 of Cohesion's associations endpoints
    class AssociationV1
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def normalize_entity(e)
        # create a new entity if what's passed in an Array
        e = Entity.new(id: e[1], kind: e[0]) if e.is_a?(Array)

        # ID should be a string
        e.id = e.id.to_s if !e.is_a?(String)

        # otherwise return back what was passed in
        e
      end

      # different_entities returns true if the entities are different, otherwise
      # it will raise an Argumenterror
      # e.g. a user should not be able to follow itself
      def different_entities?(from_entity, to_entity)
        if from_entity.kind == to_entity.kind && from_entity.id == to_entity.id
          fail ArgumentError, 'from and to entities cannot be the same'
        end
        true
      end

      # empty_data will raise an error if the data bag is empty as this means
      # there is nothing to be updated
      def empty_data?(data)
        fail ArgumentError, 'no associations to be updated' if data == {}

        false
      end

      def create(from:, kind:, to:, data: {})
        from_entity = normalize_entity(from)
        to_entity = normalize_entity(to)

        different_entities?(from_entity, to_entity)

        client.put("/v1/associations/#{from_entity.kind}/#{from_entity.id}"\
                   "/#{kind}/#{to_entity.kind}/#{to_entity.id}", data)

        Cohesion::Association.new(
          kind: kind, from: from_entity, to: to_entity,
          data: data, time: DateTime.now
        )
      end

      def delete(from:, kind:, to:)
        from_entity = normalize_entity(from)
        to_entity = normalize_entity(to)

        different_entities?(from_entity, to_entity)

        client.delete("/v1/associations/#{from_entity.kind}/#{from_entity.id}"\
                      "/#{kind}/#{to_entity.kind}/#{to_entity.id}")

        true
      end

      def bulk_delete(from:, kind:, bulk_kind:)
        from_entity = normalize_entity(from)

        client.delete("/v1/associations/#{from_entity.kind}/#{from_entity.id}/"\
                      "#{kind}/#{bulk_kind}")

        true
      end

      def update(from:, kind:, to:, data: {})
        from_entity = normalize_entity(from)
        to_entity = normalize_entity(to)

        client.post("/v1/associations/#{from_entity.kind}/#{from_entity.id}/"\
                    "#{kind}/#{to_entity.kind}/#{to_entity.id}", data)

        true
      end

      def batch_update(from:, kind:, bulk_kind:, data:)
        empty_data?(data)
        from_entity = normalize_entity(from)

        client.patch("/v1/associations/#{from_entity.kind}/#{from_entity.id}/"\
                     "#{kind}/#{bulk_kind}", data)

        true
      end

      def bulk_update(from:, kind:, bulk_kind:, data:)
        empty_data?(data)
        from_entity = normalize_entity(from)

        client.post("/v1/associations/#{from_entity.kind}/#{from_entity.id}/"\
                    "#{kind}/#{bulk_kind}", data)

        true
      end

      def fetch(from:, kind:, to:, priority: '')
        from_entity = normalize_entity(from)
        to_entity = normalize_entity(to)

        # Return if from and to are the same entity
        if from_entity.kind == to_entity.kind && from_entity.id == to_entity.id
          return nil
        end

        begin
          path = "/v1/associations/#{from_entity.kind}/#{from_entity.id}/"\
                 "#{kind}/#{to_entity.kind}/#{to_entity.id}"
          if !priority.nil? && !priority.empty?
            path = "#{path}?priority=#{priority}"
          end

          response = client.get(path)
        rescue Faraday::Error::ResourceNotFound
          return nil
        end

        Cohesion::Association.from_hash(response)
      end

      def list(from:, kind:, bulk_kind:, sort: 'desc', offset: 0, limit: 30, priority: '', cursor: '')
        from_entity = normalize_entity(from)
        path = "/v1/associations/#{from_entity.kind}/#{from_entity.id}/"\
               "#{kind}/#{bulk_kind}?sort=#{sort}&limit=#{limit}"
        if offset != 0
          path = "#{path}&offset=#{offset}"
        end
        if !cursor.nil? && !cursor.empty?
          path = "#{path}&cursor=#{cursor}"
        end
        if !priority.nil? && !priority.empty?
          path = "#{path}&priority=#{priority}"
        end
        response = client.get(path)

        {:cursor => response['cursor'] || '', :results => Cohesion::Association.list_from_hash(response)}
      end

      def count(from:, kind:, bulk_kind:)
        from_entity = normalize_entity(from)
        response = client.get("/v1/associations/#{from_entity.kind}/"\
                              "#{from_entity.id}/#{kind}/#{bulk_kind}/count")
        response['count']
      end

      def batch(operations:)
        data = []
        operations.each do |operation, assoc|
          oper = assoc.to_hash
          oper['operation'] = operation

          data << oper
        end
        client.post('/v1/associations/batch', data)
        true
      end
    end
  end
end
