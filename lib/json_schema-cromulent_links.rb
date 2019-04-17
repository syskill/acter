require 'json_schema'
require 'json_schema/schema'

module JsonSchema
  class Schema
    def cromulent_links
      links.select(&:cromulent?)
    end

    class Link
      def cromulent?
        href && method && title
      end
    end
  end
end
