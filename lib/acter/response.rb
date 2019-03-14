require "multi_json"
require "rouge"
require "stringio"

module Acter
  class Response
    def initialize(status, headers, body)
      @status = status
      @success = (200..299).include?(status[/\d+/])
      @headers = headers.sort.map {|a| a.join(": ") }
      @body = case body
        when String
          @body_is_json = false
          body
        else
          @body_is_json = true
          MultiJson.dump(body, pretty: true)
        end
    end

    def self.new_from_faraday(faraday_response)
      status_string = "#{faraday_response.status} #{faraday_response.reason_phrase}"
      new(status_string, response.headers, response.body)
    end

    attr_reader :status, :success, :headers, :body, :body_is_json
    alias_method :success?, :success
    alias_method :body_is_json?, :body_is_json
    remove_method :success
    remove_method :body_is_json

    def render(show_body: true, show_headers: false, color: true)
      StringIO.open do |s|
        s << status << "\n"
        if show_headers
          headers.each {|h| s << h << "\n" }
        end
        if show_body
          s << "\n"
          unless color
            s << body
          else
            lexer = body_is_json? ? Rouge::Lexers::JSON : Rouge::Lexers::HTML
            s << Rouge::Formatters::Terminal256.format(lexer.new.lex(body), theme: "monokai")
          end
          s << "\n"
        end
        s.string
      end
    end
  end
end
