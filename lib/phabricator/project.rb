require 'phabricator/conduit_client'

module Phabricator
  class Project
    @@cached_projects = {}

    attr_reader :id, :phid
    attr_accessor :name

    def self.populate_all
      response = client.request(:post, 'project.query')

      response['result']['data'].each do |phid, data|
        project = Project.new(data)
        @@cached_projects[project.name] = project
      end
    end

    def self.find_by_name(name)
      populate_all if @@cached_projects.empty?

      @@cached_projects[name] || refresh_cache_for_project(name)
    end

    def self.find_by_id(id)
      # Re-populate if we couldn't find it in the cache (this applies to
      # if the cache is empty as well).
      populate_all unless @@cached_projects.find{|k,p| p.phid == id}
      _, v = @@cached_projects.find{|k,p| p.phid == id}
      v
    end

    def initialize(attributes)
      @id = attributes['id']
      @phid = attributes['phid']
      @name = attributes['name']
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end

    def self.refresh_cache_for_project(name)
      response = client.request(:post, 'project.query', { names: [ name ] })
      response['result']['data'].each do |phid, data|
        project = Project.new(data)
        @@cached_projects[project.name] = project
      end

      @@cached_projects[name]
    end
  end
end
