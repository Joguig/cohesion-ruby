Gem::Specification.new do |s|
  s.name = 'cohesion'
  s.version = '0.0.2'
  s.authors = ['cohesion-devs@justin.tv']
  s.date = '2015-04-20'
  s.files = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.description = 'Client for cohesion service'
  s.summary = 'Client for cohesion service'

  s.add_dependency 'faraday'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'hystrix-ruby'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rubocop'
end
