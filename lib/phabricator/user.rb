require 'phabricator/conduit_client'

module Phabricator
  class User
    @@cached_users = {}
    @@cached_projects_id = {}

    attr_reader :phid
    attr_accessor :name

    def self.populate_all
      response = client.request(:post, 'user.query')

      response['result'].each do |data|
        user = User.new(data)
        @@cached_users[user.name] = user
      end

    end

    def self.find_by_name(name)
      # Re-populate if we couldn't find it in the cache (this applies to
      # if the cache is empty as well).
      populate_all unless @@cached_users[name]

      @@cached_users[name]
    end

    def self.find_by_id(id)
      # Re-populate if we couldn't find it in the cache (this applies to
      # if the cache is empty as well).
      populate_all unless @@cached_users.find{|n,a| a.phid == id}
      _, v = @@cached_users.find{|n,a| a.phid == id}
      v
    end

    def initialize(attributes)
      @phid = attributes['phid']
      @name = attributes['userName']
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
