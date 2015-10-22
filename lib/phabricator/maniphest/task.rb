require 'phabricator/conduit_client'
require 'phabricator/project'
require 'phabricator/user'

module Phabricator::Maniphest
  class Task < Phabricator::PhabObject
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

        def raw_value_from_name(name)
          PRIORITIES.fetch(name.to_sym)
        end

        def name_from_raw_value(raw_value)
          PRIORITIES.invert.fetch(raw_value).to_s
        end
      end
    end

    # @override PhabObject
    def self.api_name
      'maniphest'
    end

    def self.create_verb
      'createtask'
    end

    prop :id
    prop :title
    prop :description
    prop :priority

    prop :priority, class: Priority, name_prop: :priorityName
    prop :projectPHIDs, class: Phabricator::Project, name_prop: :projectNames
    prop :ccPHIDs, class: Phabricator::User, name_prop: :ccNames
    prop :ownerPHID, class: Phabricator::User, name_prop: :ownerName, query_prop: :ownerPHIDs, query_name_prop: :ownerNames

    def get_url
      "https://phab.stripe.com/T#{id}"
    end
  end
end
