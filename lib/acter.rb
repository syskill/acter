require "acter/version"
require "json_schema-cromulent_links"
require "json_schema-example_parsing"

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

  def self.main
  end

  def self.program_name
    @@program_name ||= File.basename($0, ".rb")
  end
end
