# frozen_string_literal: true

require_relative "google_parser"

class Search
  class << self
    def query(query, provider = "google")
      parser = GoogleParser.new(execute_query)
      parser.knowledge_card
    end

    def execute_query
      # to be implemented
    end
  end
end
