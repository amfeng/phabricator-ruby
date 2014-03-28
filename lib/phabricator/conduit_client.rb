require 'json'
require 'singleton'
require 'rest-client'

module Phabricator
  class ConduitClient
    include Singleton

    def initialize
      # Find the .arcrc file for Phabricator credentials.
      filename = File.expand_path('~/.arcrc')

      if File.readable?(filename)
        @settings = JSON.parse(File.read(filename))['hosts'].first
      else
        raise '~/.arcrc does not exist or is not readable.'
      end

      connect
    end

    def connect
      token = Time.now.to_i

      data = {
        client: 'phabricator-ruby',
        clientVersion: Phabricator::VERSION,
        user: credentials['user'],
        host: host,
        authToken: token,
        authSignature: Digest::SHA1.hexdigest("#{token}#{credentials['cert']}")
      }

      response = JSON.parse(post('conduit.connect', data, __conduit__: true))

      # TODO: Something something error handling

      @conduit = {
        connectionID: response['result']['connectionID'],
        sessionKey: response['result']['sessionKey']
      }
    end

    def request(http_method, method, data={})
      # TODO: validation on http_method
      self.send(http_method, method, data.merge(__conduit__: @conduit))
    end

    private

    def post(method, data, opts={})
      RestClient.post("#{host}#{method}", {
        params: data.to_json,
        output: 'json'
      }.merge(opts))
    end

    def host
      @settings[0]
    end

    def credentials
      @settings[1]
    end
  end
end
