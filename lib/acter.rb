require "acter/version"
require "json_schema-cromulent_links"
require "json_schema-example_parsing"
require "multi_json"
require "open-uri"
require "pathname"
require "yaml"

module Acter
  autoload :Action, "acter/action"
  autoload :Error, "acter/error"
  autoload :Help, "acter/help"
  autoload :Request, "acter/request"
  autoload :Response, "acter/response"
  autoload :Result, "acter/result"

  autoload :NoSchema, "acter/error"
  autoload :InvalidSchema, "acter/error"
  autoload :InvalidCommand, "acter/error"
  autoload :InvalidSubject, "acter/error"
  autoload :InvalidAction, "acter/error"
  autoload :MissingParameters, "acter/error"
  autoload :HelpWanted, "acter/error"

  class << self
    def load_schema_data(path = nil)
      path ||= Pathname.glob("schema.{json,yml}").first or raise NoSchema
      if path.is_a?(String)
        uri = URI(path)
        source = uri.scheme ? uri : Pathname.new(path)
      elsif path.respond_to?(:read) && path.respond_to?(:to_s)
        source = path
      else
        raise ArgumentError, "Argument to load_schema must be a String or a Pathname-like object"
      end
      if source.to_s =~ /\.ya?ml$/
        YAML.load(source.read)
      else
        MultiJson.load(source.read)
      end
    end

    def handle_invalid_command(exn)
      puts exn
      puts
      help = Help.new(exn.schema)
      case exn
      when HelpWanted, MissingParameters
        puts help.help_for_action(exn.action, exn.subject)
      when InvalidAction
        puts help.help_for_subject(exn.subject)
      else
        puts help.general_help
      end
    end

    def run(args, schema_path = nil, render_options = nil)
      schema_data = load_schema_data(schema_path)
      action = Action.new(args, schema_data)
      result = action.send_request
      puts result.render(render_options)
      result.success?
    rescue InvalidCommand => e
      handle_invalid_command(e)
    rescue NoSchema
      raise unless args.empty? || args == %w"help"
      handle_invalid_command(InvalidCommand.new(nil))
    end

    def program_name
      @program_name ||= File.basename($0, ".rb")
    end

    attr_accessor :help_wanted, :options_text
    alias help_wanted? help_wanted
  end
end
