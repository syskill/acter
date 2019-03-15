module Acter
  class Error < StandardError
  end

  class InvalidSchema < Error
    def initialize(message, errors = nil)
      @message = message
      @errors = Array(errors)
    end
    attr_reader :message
    def to_s
      @errors.dup.unshift(@message).join("\n\t")
    end
  end

  class InvalidAction < Error
  end

  class MissingParameters < Error
    def initialize(params)
      @params = params
    end
    def message
      "Missing required parameters"
    end
    def to_s
      "#{message}: #{@params.map(&:inspect).join(", ")}"
    end
  end
end
