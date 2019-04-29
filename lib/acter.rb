require "acter/version"
require "json_schema-cromulent_links"
require "json_schema-example_parsing"
require "multi_json"
require "open-uri"
require "pathname"

module Acter
  autoload :Action, "acter/action"
  autoload :Error, "acter/error"
  autoload :Help, "acter/help"
  autoload :Request, "acter/request"
  autoload :Response, "acter/response"
  autoload :Result, "acter/result"

  autoload :InvalidSchema, "acter/error"
  autoload :InvalidCommand, "acter/error"
  autoload :InvalidSubject, "acter/error"
  autoload :InvalidAction, "acter/error"
  autoload :MissingParameters, "acter/error"

  def self.load_schema_data(path = nil)
    path ||= Pathname.glob("schema.{json,yml}").first
    if path.is_a?(String)
      uri = URI(path)
      source = uri.scheme ? uri : Pathname.new(path)
    elsif path.respond_to?(:read) && path.respond_to?(:to_s)
      source = path
    else
      raise ArgumentError, "Argument to load_schema must be a String or a Pathname-like object"
    end
    MultiJson.load(source.read)
  end

  def self.handle_invalid_command(exn)
    puts exn
    puts
    help = Help.new(exn.schema)
    case exn
    when MissingParameters
      puts help.help_for_action(exn.action, exn.subject)
    when InvalidAction
      puts help.help_for_subject(exn.subject)
    else
      puts help.general_help
    end
  end

  def self.run(args, schema_path = nil, render_options = nil)
    schema_data = load_schema_data(schema_path)
    action = Action.new(args, schema_data)
    result = action.send_request
    puts result.render(render_options)
    result.success?
  rescue InvalidCommand => e
    handle_invalid_command(e)
  end

  def self.program_name
    @@program_name ||= File.basename($0, ".rb")
  end

  class << self; attr_accessor :options_text end
end
