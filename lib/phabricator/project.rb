require 'phabricator/conduit_client'

module Phabricator
  class Project < PhabObject
    @@cached_projects = {}

    prop :id
    prop :name

    def self.populate_all
      query.each do |project|
        @@cached_projects[project.name] = project
      end
    end

    def self.find_by_name(name)
      populate_all if @@cached_projects.empty?

      @@cached_projects[name] || refresh_cache_for_project(name)
    end

    def self.raw_value_from_name(name)
      find_by_name(name).phid
    end

    def self.name_from_raw_value(raw_value)
      # TODO: implement me
      raise NotImplementedError
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
