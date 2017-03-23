module Phabricator
  class Error < StandardError; end

  module Errors
    class ClientError < Error
      attr_accessor :code

      def initialize(code)
        @code = code
      end
    end
  end
end