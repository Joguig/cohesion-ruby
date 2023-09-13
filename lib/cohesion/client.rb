require 'faraday'
require 'faraday_middleware'

require 'cohesion/api/v1/associations'

module Cohesion
  # Client creates connections for http requests and returns the body of the
  # response
  class Client
    attr_accessor :version, :endpoint, :source
    attr_accessor :associations
    attr_accessor :conn

    def initialize
      yield self if block_given?

      self.source = "code.justin.tv/#{source}" unless source.nil?
      setup_version

      self.conn = Faraday.new(url: endpoint) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response :json
        faraday.use Faraday::Response::RaiseError
      end
    end

    def setup_version
      self.version = 1 if version.nil?

      case version
      when 1
        self.associations = Cohesion::API::AssociationV1.new(self)
      end
    end

    def get(path)
      response = conn.get do |req|
        req.url path
        req.headers['Twitch-Repository'] = source if source
      end
      response.body
    end

    def put(path, data)
      response = conn.put do |req|
        req.url path
        req.headers['Content-Type'] = 'application/json'
        req.headers['Twitch-Repository'] = source if source
        req.body = data.to_json
      end
      response.body
    end

    def post(path, data)
      response = conn.post do |req|
        req.url path
        req.headers['Content-Type'] = 'application/json'
        req.headers['Twitch-Repository'] = source if source
        req.body = data.to_json
      end
      response.body
    end

    def patch(path, data)
      response = conn.patch do |req|
        req.url path
        req.headers['Content-Type'] = 'application/json'
        req.headers['Twitch-Repository'] = source if source
        req.body = data.to_json
      end
      response.body
    end

    def delete(path)
      response = conn.delete do |req|
        req.url path
        req.headers['Twitch-Repository'] = source if source
      end
      response.body
    end
  end
end
