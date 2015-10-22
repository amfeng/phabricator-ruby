require 'phabricator/conduit_client'

module Phabricator
  class PhabObject
    attr_reader :phid

    def initialize(attributes)
      @phid = attributes['phid']
    end

    def self.api_name
      self.name.split('::').last.downcase
    end

    def self.query(fields={})
      response = client.request(:post, "#{api_name}.query", fields)
      items = response['result']

      # Phab is horrible; some endpoints put use a 'data' subhash, some don't
      if items.is_a?(Hash) && items.key?('data')
        items = items['data']
      end

      # Phab is even more horrible; some endpoints return an array, some index by phid
      if items.is_a?(Hash)
        items = items.values
      end

      items.map {|item| self.new(item)}
    end

    private

    def self.client
      @client ||= Phabricator::ConduitClient.instance
    end
  end
end
