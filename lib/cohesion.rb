require 'cohesion/association'
require 'cohesion/client'
require 'cohesion/entity'
require 'cohesion/commands'

require 'logger'

# Cohesion module for the gem
module Cohesion
  def self.logger
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end
end

Cohesion.logger = Logger.new(STDOUT)
Cohesion.logger.level = Logger::WARN
