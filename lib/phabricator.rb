require 'phabricator/config'
require 'phabricator/version'

module Phabricator
  extend Phabricator::Config
end

require 'phabricator/conduit_client'
require 'phabricator/maniphest'
