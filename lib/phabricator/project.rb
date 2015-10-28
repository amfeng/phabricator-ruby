require 'phabricator/conduit_client'

module Phabricator
  class Project < PhabObject
    @@cached_projects = {}

    prop :id
    prop :name

    def self.populate_all
      query.each do |project|
        @@cached_projects[project.name.downcase] = project
      end
    end

    def self.find_by_name(name)
      populate_all if @@cached_projects.empty?

      @@cached_projects[name.downcase] || refresh_cache_for_project(name)
    end

    def self.raw_value_from_name(name)
      return nil if name.nil?

      project = find_by_name(name)
      return nil if project.nil?
      return project.phid
    end

    def self.name_from_raw_value(raw_value)
      # TODO: implement me
      raise NotImplementedError
    end

    private

    def self.refresh_cache_for_project(name)
      query(names: [name]).each do |project|
        @@cached_projects[project.name.downcase] = project
      end

      @@cached_projects[name.downcase]
    end
  end
end
