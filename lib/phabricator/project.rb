require 'phabricator/conduit_client'

module Phabricator
  class Project < PhabObject
    @@cached_projects = {}

    attr_reader :id
    attr_accessor :name

    def self.populate_all
      query.each do |project|
        @@cached_projects[project.name] = project
      end
    end

    def self.find_by_name(name)
      populate_all if @@cached_projects.empty?

      @@cached_projects[name] || refresh_cache_for_project(name)
    end

    def initialize(attributes)
      super
      @id = attributes['id']
      @name = attributes['name']
    end

    private

    def self.refresh_cache_for_project(name)
      query(names: [name]).each do |project|
        @@cached_projects[project.name] = project
      end

      @@cached_projects[name]
    end
  end
end
