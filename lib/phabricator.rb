require 'phabricator/config'
require 'phabricator/version'
require 'phabricator/logging'

module Phabricator
  extend Phabricator::Config

  def self.lookup_project(item)
    return item if item.kind_of?(::Phabricator::Project)
    return ::Phabricator::Project.find_by_name(item)
  end

  def self.lookup_user(item)
    return item if item.kind_of?(::Phabricator::User)
    return ::Phabricator::User.find_by_name(item)
  end
end

require 'phabricator/conduit_client'
require 'phabricator/maniphest'
