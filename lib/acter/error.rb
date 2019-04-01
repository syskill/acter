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

  class InvalidCommand < Error
    def initialize(schema, subject = nil, action = nil, params = nil)
      @schema = schema
      @subject = subject
      @action = action
      @params = params
    end
    attr_reader :schema, :subject, :action, :params
    def to_s
      "Invalid command"
    end
  end

  class InvalidSubject < InvalidCommand
    def initialize(subject, schema)
      super(schema, subject)
    end
    def message
      "No such property"
    end
    def to_s
      "#{message}: #{@subject.inspect}"
    end
  end

  class InvalidAction < InvalidCommand
    def initialize(action, subject, schema)
      super(schema, subject, action)
    end
    def message
      "Property has no valid link for action"
    end
    def to_s
      "#{message}: #{@subject.inspect} -> #{@action.inspect}"
    end
  end

  class MissingParameters < InvalidCommand
    def initialize(params, action, subject, schema)
      super(schema, subject, action, params)
    end
    def message
      "Missing required parameters"
    end
    def to_s
      "#{message}: #{@params.map(&:inspect).join(", ")}"
    end
  end
end
