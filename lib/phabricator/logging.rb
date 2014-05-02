require 'logger'

module Phabricator
  module Logging
    def log
      @log ||= Logger.new(STDOUT)
      @log.level = Phabricator.log_level || Logger::ERROR

      @log
    end
  end
end
