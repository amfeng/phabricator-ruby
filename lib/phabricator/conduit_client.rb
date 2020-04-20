require 'json'
require 'singleton'
require 'rest-client'
require 'phabricator/errors'

module Phabricator
  class ConduitClient
    include Singleton
    include Logging

    attr_reader :host

    def initialize
      @host  = Phabricator.host
      @token = Phabricator.api_token

      if @token.present?
        @conduit = { token: @token }
        return
      end

      @credentials = {
          user: Phabricator.user,
          cert: Phabricator.cert
      }

      # The config is incomplete; try to get the credentials off the ~/.arcrc
      # file instead.
      if @host.nil? || @credentials.values.any? { |v| v.nil? }
        get_credentials_from_file
      end

      connect
    end

    def connect
      token = Time.now.to_i

      data = {
          client:        'phabricator-ruby',
          clientVersion: Phabricator::VERSION,
          user:          @credentials[:user],
          host:          @host,
          authToken:     token,
          authSignature: Digest::SHA1.hexdigest("#{token}#{@credentials[:cert]}")
      }

      response = post('conduit.connect', data, __conduit__: true)

      log.info("Successful Conduit connection.")
      @conduit = {
          connectionID: response['result']['connectionID'],
          sessionKey:   response['result']['sessionKey']
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

        @host         = settings['config']['phabricator.uri']
        @credentials  = {
            user: user_settings[1]['user'],
            cert: user_settings[1]['cert']
        }
      else
        raise 'No credentials passed in, and ~/.arcrc does not exist or is \
          not readable.'
      end
    end

    def post(method, data, opts={})
      log.debug("Making a `#{method}` request with data: #{data.inspect}.")
      response = RestClient.post("#{@host}/api/#{method}", {
                    params: data.to_json,
                    output: 'json',
                    max_redirects: 0
                  }.merge(opts)) do |res|
                    case res.code
                    when 300, 301, 302, 303, 307, 308
                      log.error("Conduit response: #{res.inspect}, response code: #{res.code}")
                      raise Errors::ClientError.new(res.code), 'Conduit connection error: the host used in the url is used to redirect the request'
                    else
                      res.return!
                    end
                  end
      response = JSON.parse(response)

      if response['result']
        response
      else
        log.error("Conduit response: #{response.inspect}")

        raise Errors::ClientError.new(response['error_code']), "Conduit connection error: #{response['error_code']} info: \
        #{response['error_info']}"
      end
    end
  end
end
