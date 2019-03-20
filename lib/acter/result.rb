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
        s << response.status << "\n"
        if options[:show_headers]
          response.headers.each {|h| s << h << "\n" }
        end
        if options[:show_body]
          s << "\n"
          unless options[:color]
            s << response.body
          else
            lexer = response.body_is_json? ? Rouge::Lexers::JSON : Rouge::Lexers::HTML
            s << Rouge::Formatters::Terminal256.format(lexer.new.lex(response.body), theme: options.fetch(:theme, DEFAULT_THEME))
          end
          s << "\n"
        end
        s.string
      end
    end
  end
end
