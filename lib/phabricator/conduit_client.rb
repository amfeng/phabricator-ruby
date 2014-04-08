require 'json'
require 'singleton'
require 'rest-client'

module Phabricator
  class ConduitClient
    include Singleton

    def initialize
      @host = Phabricator.host
      @credentials = {
        user: Phabricator.user,
        cert: Phabricator.cert
      }

      # The config is incomplete; try to get the credentials off the ~/.arcrc
      # file instead.
      if @host.nil? || @credentials.values.any? {|v| v.nil?}
        get_credentials_from_file
      end

      connect
    end

    def connect
      token = Time.now.to_i

      data = {
        client: 'phabricator-ruby',
        clientVersion: Phabricator::VERSION,
        user: @credentials[:user],
        host: @host,
        authToken: token,
        authSignature: Digest::SHA1.hexdigest("#{token}#{@credentials[:cert]}")
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

    def get_credentials_from_file
      filename = File.expand_path('~/.arcrc')

      if File.readable?(filename)
        settings = JSON.parse(File.read(filename))
        user_settings = settings['hosts'].first

        @host = settings['config']['phabricator.uri']
        @credentials = {
          user: user_settings[1]['user'],
          cert: user_settings[1]['cert']
        }
      else
        raise 'No credentials passed in, and ~/.arcrc does not exist or is \
          not readable.'
      end
    end

    def post(method, data, opts={})
      RestClient.post("#{@host}/api/#{method}", {
        params: data.to_json,
        output: 'json'
      }.merge(opts))
    end
  end
end
