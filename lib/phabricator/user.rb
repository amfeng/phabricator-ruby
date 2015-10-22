require 'phabricator/conduit_client'

module Phabricator
  class User
    @@cached_users = {}

    attr_reader :phid
    attr_accessor :name

    def self.populate_all
      response = client.request(:post, 'user.query', {limit: 1000})

      response['result'].each do |data|
        user = User.new(data)
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
    end

    private

    def self.refresh_cache_for_user(name)
      response = client.request(:post, 'user.query', { usernames: [ name ] })
      response['result'].each do |data|
        user = User.new(data)
        @@cached_users[user.name] = user
      end

      @@cached_users[user.name]
    end

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
