module Acter
  class Error < StandardError
  end

  class InvalidSchema < Error
  end

  class InvalidAction < Error
  end

  class MissingParameters < Error
  end
end
