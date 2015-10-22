require 'phabricator/conduit_client'

module Phabricator
  class User < PhabObject
    @@cached_users = {}

    attr_accessor :phid, :name, :attrs

    def self.populate_all
      query.each do |user|
        @@cached_users[user.name] = user
      end
    end

    def self.find_by_name(name)
      populate_all if @@cached_users.empty?

      @@cached_users[name] || refresh_cache_for_user(name)
    end

    def initialize(attributes)
      @phid = attributes['phid']
      @name = attributes['userName']
      @attrs = attributes
    end

    private

    def self.refresh_cache_for_user(name)
      query(usernames: [name]).each do |user|
        @@cached_users[user.name] = user
      end
      @@cached_users[name]
    end
  end
end
