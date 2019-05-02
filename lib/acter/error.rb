module Acter
  class Error < StandardError
  end

  class NoSchema < Error
    def to_s
      "Schema not found"
    end
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
      if @schema.nil?
        "Command-line help"
      else
        "Invalid command"
      end
    end
  end

  class InvalidSubject < InvalidCommand
    def initialize(subject, schema)
      super(schema, subject)
    end
    def message
      "Invalid subject"
    end
    def to_s
      if @subject.nil? || @subject == "help"
        "Command-line help"
      else
        "#{message}: #{@subject.inspect}"
      end
    end
  end

  class InvalidAction < InvalidCommand
    def initialize(action, subject, schema)
      super(schema, subject, action)
    end
    def message
      "No valid link for action"
    end
    def to_s
      if @action.nil? || @action == "help"
        "Command-line help"
      else
        "#{message}: #{@subject.inspect} -> #{@action.inspect}"
      end
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

  class HelpWanted < InvalidCommand
    def initialize(action, subject, schema)
      super(schema, subject, action)
    end
    def to_s
      "Command-line help"
    end
  end
end
