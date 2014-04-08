require_relative 'phabricator/config'
require_relative 'phabricator/version'

module Phabricator
  extend Phabricator::Config
end

require_relative 'phabricator/conduit_client'
require_relative 'phabricator/maniphest'
