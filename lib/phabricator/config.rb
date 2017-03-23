module Phabricator
  module Config
    attr_accessor :host, :user, :cert, :log_level, :api_token

    def configure
      yield self
    end
  end
end
