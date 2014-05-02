module Phabricator
  module Config
    attr_accessor :host, :user, :cert, :log_level

    def configure
      yield self
    end
  end
end
