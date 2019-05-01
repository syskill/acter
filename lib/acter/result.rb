require "forwardable"
require "rouge"
require "stringio"
require "term/ansicolor"

module Acter
  class Result
    extend Forwardable

    DEFAULT_RENDER_OPTIONS = {
      show_body: true,
      show_headers: false,
      color: :tty?,
      theme: "monokai",
    }

    def initialize(response)
      @response = response
    end

    attr_reader :response
    def_delegator :@response, :success?

    def render(options = nil)
      options = DEFAULT_RENDER_OPTIONS.merge(Hash(options))
      if block_given?
        more_options = yield response
        options.merge!(Hash(more_options))
      end

      colorize = options[:color] && (options[:color] != :tty? || $>.tty?)

      StringIO.open do |s|
        if colorize
          s.puts Term::ANSIColor.bold(response.status)
        else
          s.puts response.status
        end
        if options[:show_headers]
          response.headers.each(&s.method(:puts))
        end
        if options[:show_body]
          s.puts
          if colorize
            lexer = response.body_is_json? ? Rouge::Lexers::JSON : Rouge::Lexers::HTML
            s.puts Rouge::Formatters::Terminal256.format(lexer.new.lex(response.body), theme: options[:theme])
          else
            s.puts response.body
          end
        end
        s.string
      end
    end
  end
end
