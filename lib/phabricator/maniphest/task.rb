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
    attr_accessor :title, :description, :priority, :projects, :status, :created, :author, :ccs, :depends_on

    def self.create(title, description=nil, projects=[], priority='normal', owner=nil, ccs=[], other={})
      response = client.request(:post, 'maniphest.createtask', {
        title: title,
        description: description,
        priority: Priority.send(priority),
        projectPHIDs: projects.compact.map { |p| ::Phabricator.lookup_project(p).phid },
        ownerPHID: owner.nil? ? nil : ::Phabricator.lookup_user(owner).phid,
        ccPHIDs: ccs.compact.map { |c| ::Phabricator.lookup_user(c).phid }
      }.merge(other))

      data = response['result']

      # TODO: Error handling

      self.new(data)
    end

    def self.retrieve(id)
      response = client.request(:post, 'maniphest.info', {
        task_id: id.to_i,
      })

      data = response['result']

      # TODO: Error handling

      self.new(data)
    end

    def self.query(options = {})
      options = {
        status: nil,
        order: 'order-created',
        limit: 20,
        offset: 0,
        phids: nil
      }.merge(options)

      response = client.request(:post, 'maniphest.query', {
        status: options[:status],
        order: options[:order],
        limit: options[:limit],
        offset: options[:offset],
        phids: options[:phids],
      })

      data = response['result']

      tasks = []

      data.each do |k, v|
        if not %w{error_code error_info}.include?(k)
          tasks << self.new(v)
        end
      end
      
      tasks
    end

    def self.statuses
      response = client.request(:post, 'maniphest.querystatuses', {
      })
      response['result']
    end

    def transactions
      if @transactions_.nil?
        client = Phabricator::ConduitClient.instance
        response = client.request(:post, 'maniphest.gettasktransactions', {
          ids: [@id],
        })
        @transactions_ = response['result'][@id]
      end
      @transactions_
    end

    def initialize(attributes)
      @id = attributes['id']
      @title = attributes['title']
      @description = attributes['description']
      @priority = attributes['priority']
      @status = attributes['status']
      @projects = attributes['projectPHIDs']
      @projects = attributes['projectPHIDs']
      @ccs = attributes['ccPHIDs']
      @depends_on = attributes['dependsOnTaskPHIDs']

      @author = Phabricator::User.find_by_id(attributes['authorPHID'])
      @created = Time.at(attributes['dateCreated'].to_i).utc
      @transactions_ = nil
    end

    def update(attributes)
     response = self.class.client.request(:post, 'maniphest.update',
       {id: @id}.merge(attributes))
     data = response['result']
     self.class.new(data) 
    end

    def get_url()
      "https://phab.stripe.com/T" + @id
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
