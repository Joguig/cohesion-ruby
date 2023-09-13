cohesion-ruby
=============

Ruby client for cohesion service

# Usage

```ruby
client = Cohesion::Client.new do |config|
	config.version = 1
	config.endpoint = "http://cohesion.internal.justin.tv"
end

# Create
association = client.associations.create(from: ["user", 1], type: "follows", to: ["user", 2], data: { foo: "bar" })
# => Cohesion::Association

# Fetch
association = client.associations.fetch(from: ["user", 1], type: "follows", to: ["user", 2])
p association.data
# => { foo: "bar" }

# List and count
associations, total = client.associations.list(from: ["user", 1], type: "followed_by", sort: "desc", limit: 100, offset: 0)
```