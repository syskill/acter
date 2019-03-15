require "active_support/core_ext/object/try"
require "active_support/core_ext/string/inflections"
require "cgi"
require "multi_json"
require "prmd"

module Acter
  class Action
    def initialize(args, schema)
      @subject, @name = args.shift(2)

      @params = {}
      @headers = {}
      args.each_with_index do |arg, idx|
        case arg
        when /^(?<key>[^:=]+):(?<value>.*)/
          warn "Value of header #{key.inspect} is empty" if value.empty?
          @headers[key] = value
        when /^(?<key>[^:=]+)=(?<value>.*)/
          @params[key] = try_json_value(value)
        else
          if idx.zero?
            @params[@subject] = try_json_value(value)
          else
            raise ArgumentError, arg.inspect
          end
        end
      end

      @schema = schema
      result, errors = @schema.validate
      result or raise InvalidSchema, "JSON schema validation failed", errors
      result, errors = @schema.expand_references
      result or raise InvalidSchema, "JSON schema reference expansion failed", errors

      @base_url ||= @schema.links.find do |li|
        li.href && li.rel == "self"
      end.try(:href)
      @base_url or raise InvalidSchema, "schema has no valid link to self"

      validate_link!
      validate_params!
    end

    attr_reader :name, :subject, :params, :headers, :schema,
      :base_url, :link, :method, :path

    def send_request(&block)
      Request.new(method, base_url, path, params, headers, &block).send
    end

  private

    def try_json_value(str)
      begin
        MultiJson.load(%<{"_":#{str}}>)['_']
      rescue MultiJson::ParseError
        str
      end
    end

    def validate_link!
      schema.properties.key?(subject) or raise InvalidAction, "Schema has no property #{subject.inspect}"
      @link = schema.properties[subject].links.find do |li|
        li.href && li.method && li.title &&
          li.title.underscore == name
      end
      @link or raise InvalidAction, "schema has no valid link for action #{subject.inspect} -> #{name.inspect}"
      @method = @link.method.to_s.upcase
      @link
    end

    def validate_params!
      missing_params = []
      path_keys = link.href.scan(/\{\(([^)])+\)\}/).map do |m|
        path_param_base_name(m.first)
      end
      path_params = path_keys.each_with_object({}) do |k, hsh|
        if params.key?[k]
          hsh[k] = params.delete[k]
        else
          missing_params << k
        end
      end
      required_params = Prmd::Link.new(link.data).required_and_optional_parameters.first.keys
      missing_params.concat(required_params - params.keys)
      missing_params.empty? or raise MissingParameters, missing_params
      @path = link.href.gsub(/\{\(([^)])+\)\}/) do |m|
        "%{#{path_param_base_name(m.first)}}"
      end % path_params
      @params
    end

    def path_param_base_name(str)
      CGI.unescape(str).split("/").last
    end
  end
end
