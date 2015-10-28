require 'phabricator/conduit_client'

module Phabricator
  class User < PhabObject
    @@cached_users = {}

    prop :userName

    # alias for backwards compatibility
    def name
      userName
    end

    def self.populate_all
      query.each do |user|
        @@cached_users[user.name.downcase] = user
      end
    end

    def self.find_by_name(name)
      populate_all if @@cached_users.empty?

      @@cached_users[name.downcase] || refresh_cache_for_user(name)
    end

    def self.raw_value_from_name(name)
      return nil if name.nil?

      user = find_by_name(name)
      return nil if user.nil?
      return user.phid
    end

    def self.name_from_raw_value(raw_value)
      # TODO: implement me
      raise NotImplementedError
    end

    private

    def self.refresh_cache_for_user(name)
      query(usernames: [name]).each do |user|
        @@cached_users[user.name.downcase] = user
      end
      @@cached_users[name.downcase]
    end
  end
end
