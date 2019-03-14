require "faraday"
require "acter/response"

module Acter
  class Request
    def initialize(method, base_url, path, params = nil, headers = nil)
      @method = method.to_s.downcase
      @base_url = base_url
      @path = path
      @params = Hash(params)
      @headers = Hash(headers)
    end

    def client
      unless @client && !block_given?
        @client = Faraday.new(url: base_url) do |faraday|
          faraday.request :json
          yield faraday if block_given?
          faraday.response :json, content_type: /\bjson(?:;|$)/
          faraday.adapter Faraday.default_adapter
        end
      end
    end

    def send
      Response.new_from_faraday(client.send(@method, @path, @params, @headers))
    end
  end
end

      #options = @render_options
      #if block_given?
      #  more_options = yield response
      #  options = options.merge(Hash(more_options))
      #end
