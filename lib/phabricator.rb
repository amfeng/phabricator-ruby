require 'phabricator/version'
require 'json'
require 'rest-client'

module Phabricator
  class ConduitClient
    def initialize
      # Find the .arcrc file for Phabricator credentials.
      filename = File.expand_path('~/.arcrc')

      if File.readable?(filename)
        @settings = JSON.parse(File.read(filename))['hosts'].first
      else
        raise '~/.arcrc does not exist or is not readable.'
      end
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

      response = JSON.parse(post('conduit.connect', data))

      # TODO: Something something error handling

      @conduit = {
        connectionID: response['result']['connectionID'],
        sessionKey: response['result']['sessionKey']
      }
    end

    def post(method, data)
      RestClient.post("#{host}#{method}", {
        params: data.to_json,
        output: 'json',
        __conduit__: true
      })
    end

    private

    def host
      @settings[0]
    end

    def credentials
      @settings[1]
    end
  end
end
