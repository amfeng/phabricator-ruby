require 'phabricator/conduit_client'
require 'phabricator/project'
require 'phabricator/user'

module Phabricator::Maniphest
  class Task
    module Priority
      class << self
        # TODO: Make these priority values actually correct, or figure out
        # how to pull these programmatically.
        PRIORITIES = {
          unbreak_now: 100,
          needs_triage: 90,
          high: 80,
          normal: 50,
          low: 25,
          wishlist: 0
        }

        PRIORITIES.each do |priority, value|
          define_method(priority) do
            value
          end
        end
      end
    end

    attr_reader :id
    attr_accessor :title, :description, :priority

    def self.create(title, description=nil, projects=[], priority='normal', owner=nil, ccs=[], other={})
      response = client.request(:post, 'maniphest.createtask', {
        title: title,
        description: description,
        priority: Priority.send(priority),
        projectPHIDs: projects.map {|p| Phabricator::Project.find_by_name(p).phid },
        ownerPHID: owner ? Phabricator::User.find_by_name(owner).phid : nil,
        ccPHIDs: ccs.map {|c| Phabricator::User.find_by_name(c).phid }
      }.merge(other))

      data = response['result']

      # TODO: Error handling

      self.new(data)
    end

    def self.retrieve(id)
      response = client.request(:post, 'maniphest.createtask', {
        task_id: id,
      })

      data = response['result']

      # TODO: Error handling

      self.new(data)
    end

    def self.query(ids=[], phids=[], owners=[], authors=[], projects=[], ccs=[], 
                   full_text=[], status=nil, order=nil, limit=nil, offset=nil)
      response = client.request(:post, 'maniphest.query', {
        phids: phids,
        ids: ids,
        projectPHIDs: projects.map {|p| Phabricator::Project.find_by_name(p).phid },
        ownerPHIDs: owners.map {|o| Phabricator::User.find_by_name(o).phid },
        authorPHIDs: authors.map {|a| Phabricator::User.find_by_name(a).phid },
        ccPHIDs: ccs.map {|c| Phabricator::User.find_by_name(c).phid }
        order: order,
        limit: limit,
        offset: offset,
      }

      data = response['result']

      puts data

      self.new(data)
    end

    def initialize(attributes)
      @id = attributes['id']
      @title = attributes['title']
      @description = attributes['description']
      @priority = attributes['priority']
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
