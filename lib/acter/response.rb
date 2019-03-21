require "multi_json"

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
      new(status_string, faraday_response.headers, faraday_response.body)
    end

    attr_reader :status, :success, :headers, :body, :body_is_json
    alias_method :success?, :success
    alias_method :body_is_json?, :body_is_json
    remove_method :success
    remove_method :body_is_json
  end
end
