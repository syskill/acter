require "acter/version"

module Acter
  autoload :Action, "acter/action"
  autoload :Request, "acter/request"
  autoload :Response, "acter/response"
  autoload :Result, "acter/result"

  autoload :Error, "acter/error"
  autoload :InvalidSchema, "acter/error"
  autoload :InvalidAction, "acter/error"
  autoload :MissingParameters, "acter/error"

  def self.main
  end
end
