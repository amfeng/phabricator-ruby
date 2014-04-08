module Phabricator
  module Config
    attr_accessor :host, :user, :cert

    def configure
      yield self
    end
  end
end
