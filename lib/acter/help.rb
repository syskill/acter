require "active_support/core_ext/string/inflections"
require "cgi"
require "json_schema"
require "multi_json"
require "stringio"

module Acter
  class Help
    def initialize(schema)
      @schema = schema
    end

    def general_help
      StringIO.open do |s|
        s << "USAGE:  " << Acter.program_name << " <subject> <action> <params...>" << "\n"
        s << "\n" << "Perform " << @schema.description << " requests defined by JSON schema" << "\n"
        s << "\n" << "Valid subjects:" << "\n"
        @schema.properties.keys.sort.each do |subj|
          s << "   " << subj << "\n"
        end
        s.string
      end
    end

    def help_for_subject(subject)
      prop_schema = @schema.properties[subject]
      StringIO.open do |s|
        s << "USAGE:  " << Acter.program_name << " " << subject << " <action> <params...>" << "\n"
        s << "\n" << "Perform " << @schema.description << " " << prop_schema.description << " requests defined by JSON schema" << "\n"
        s << "\n" << "Valid actions:" << "\n"
        prop_schema.cromulent_links.each do |li|
          s << "   " << example_command(li) << "\n      " << li.description << "\n"
        end
        s.string
      end
    end

    def help_for_action(action, subject)
      link = @schema.properties[subject].cromulent_links.find {|li| li.title.underscore == action }
      StringIO.open do |s|
        s << "USAGE:  " << Acter.program_name << " " << subject << " " << example_command(link) << "\n"
        s << "\n" << link.description << "\n"

        if link.schema && link.schema.properties
          s << "\n" << "Parameters:" << "\n"
          link.schema.properties.map do |name, prop_schema|
            next if prop_schema.read_only?
            required = link.schema.required && link.schema.required.include?(name) ? "*REQUIRED*" : "(optional)"
            descr = nil
            if !prop_schema.default.nil?
              descr = "default #{prop_schema.default.inspect}"
            elsif !(ex = prop_schema.make_example).nil?
              descr = "e.g. #{ex.inspect}"
            elsif !prop_schema.enum.nil?
              descr = prop_schema.enum.map(&:inspect).join(", ")
            elsif !prop_schema.type.empty?
              descr = prop_schema.type.map(&:capitalize).join("|")
            end
            descr = [descr, prop_schema.description].compact.join(" - ")
            s << "   " << required << " " << name << " : " << descr << "\n"
          end
        end
        s.string
      end
    end

    def metasyntactic(property, subject = nil)
      unless property.any_of.empty?
        property.any_of.map(&method(:metasyntactic)).join("_or_")
      else
        path = property.reference ? property.reference.pointer : property.pointer
        ###pc = path.split("/")
        ###"#{pc[-3]}_#{pc[-1]}"
        path.split("/").last
      end
    end

    def example_command(link)
      subject = link.pointer.split("/")[-3]
      args = []
      link.href.scan(/\{\(([^)]+)\)\}/).each do |m|
        path = CGI.unescape(m.first)
        basename = path.split("/").last
        property = JsonPointer.evaluate(@schema, path) or
          raise InvalidSchema, "Link #{link.pointer.inspect} has invalid path parameter #{path.inspect}"
        meta = metasyntactic(property)
        if basename == subject
          args.unshift("[#{basename}=]<#{meta}>")
        else
          args << "#{basename}=<#{meta}>"
        end
      end
      if link.schema && link.schema.properties
        args << "<params...>"
      end
      args.unshift(link.title.underscore).join(" ")
    end
  end
end
