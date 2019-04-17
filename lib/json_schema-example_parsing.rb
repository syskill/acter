require 'json_schema'
require 'json_schema/parser'
require 'json_schema/schema'

module JsonSchema
  module ExampleParsing
    def parse_schema(data, parent, fragment)
      schema = super(data, parent, fragment)
      schema.example = schema.data['example']
      schema
    end
  end

  class Parser
    prepend ExampleParsing
  end

  class Schema
    attr_schema :example

    def make_example
      if example
        return example
      end
      if items
        ex = items.make_example and return Array(ex)
      end
      unless any_of.empty?
        any_of.each {|s| ex = s.make_example and return ex }
      end
      unless all_of.empty?
        any_of.each {|s| ex = s.make_example and return ex }
      end
      nil
    end
  end
end
