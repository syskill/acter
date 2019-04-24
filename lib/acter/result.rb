require "active_support/core_ext/module/delegation"
require "rouge"
require "stringio"

module Acter
  class Result
    DEFAULT_RENDER_OPTIONS = {
      show_body: true,
      show_headers: false,
      color: true,
      theme: "monokai",
    }

    def initialize(response)
      @response = response
    end

    attr_reader :response
    delegate :success?, to: :response

    def render(options = nil)
      options = DEFAULT_RENDER_OPTIONS.merge(Hash(options))
      if block_given?
        more_options = yield response
        options.merge!(Hash(more_options))
      end

      StringIO.open do |s|
        s.puts response.status
        if options[:show_headers]
          response.headers.each(&s.method(:puts))
        end
        if options[:show_body]
          s.puts
          unless options[:color]
            s.puts response.body
          else
            lexer = response.body_is_json? ? Rouge::Lexers::JSON : Rouge::Lexers::HTML
            s.puts Rouge::Formatters::Terminal256.format(lexer.new.lex(response.body), theme: options[:theme])
          end
        end
        s.string
      end
    end
  end
end
