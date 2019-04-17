require "acter/result"
require "active_support/core_ext/object/try"
require "active_support/core_ext/string/inflections"
require "cgi"
require "json_schema"
require "multi_json"

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
            @params[@subject] = try_json_value(arg)
          else
            raise ArgumentError, arg.inspect
          end
        end
      end

      @schema, errors = JsonSchema.parse(schema)
      @schema or raise InvalidSchema, "JSON schema parsing failed", errors
      result, errors = @schema.expand_references
      result or raise InvalidSchema, "JSON schema reference expansion failed", errors

      @base_url = @schema.links.find do |li|
        li.href && li.rel == "self"
      end.try(:href)
      @base_url or raise InvalidSchema, "Schema has no valid link to self"

      validate_link!
      validate_params!
    end

    attr_reader :name, :subject, :params, :headers, :schema,
      :base_url, :link, :path

    def send_request(&block)
      req = Request.new(link.method, base_url, path, params, headers)
      req.client(&block)
      Result.new(req.send)
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
      schema.properties.key?(subject) or raise InvalidSubject, subject, schema
      @link = schema.properties[subject].cromulent_links.find {|li| li.title.underscore == name }
      @link or raise InvalidAction, name, subject, schema
      @link
    end

    def validate_params!
      missing_params = []
      path_keys = link.href.scan(/\{\(([^)]+)\)\}/).map do |m|
        path_param_base_name(m.first)
      end
      path_keys.uniq! and raise InvalidSchema, "Link #{link.pointer.inspect} has multiple path parameters with same base name"
      path_params = path_keys.each_with_object({}) do |k, hsh|
        if params.key?(k)
          hsh[k.to_sym] = params.delete(k)
        else
          missing_params << k
        end
      end
      # XXX these checks seemed like a good idea, but don't work out for me
      if nil
        if link.schema && link.schema.properties
          if path_keys & link.schema.properties.keys
            raise InvalidSchema, "Path parameter base names and property names of link #{link.pointer.inspect} are not unique"
          end
          if link.schema.required
            missing_params.concat(link.schema.required - params.keys)
          end
        end
      end
      missing_params.empty? or raise MissingParameters, missing_params, name, subject, schema
      @path = link.href.gsub(/\{\(([^)]+)\)\}/) do
        "%{#{path_param_base_name($1)}}"
      end % path_params
      @params
    end

    def path_param_base_name(str)
      CGI.unescape(str).split("/").last
    end
  end
end
