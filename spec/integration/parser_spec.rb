# frozen_string_literal: true

require "spec_helper"
require_relative "../../src/search.rb"
require "json"

def load_json(path)
  file = load_file(path)
  JSON.parse(file)
end

def load_file(path)
  File.open(File.join(File.dirname(__FILE__), path)).read
end

RSpec.describe("test suites") do
  it "extracts artworks from 2024 page" do
    expectation = load_json("./stubs/vangogh_artworks_12_2024/expected_array.json")
    allow(Search).to(receive(:execute_query).and_return(load_file("./stubs/vangogh_artworks_12_2024/van-gogh-paintings.html")))
    result = Search.query("van gogh paintings")
    result[:artworks].each_with_index do |artwork, index|
      expected_hash = expectation["artworks"][index].transform_keys(&:to_sym)
      expect(artwork).to(eq(expected_hash))
    end
  end

  it "extracts artworks from 2025 page" do
    expectation = load_json("./stubs/vangogh_artworks_10_2025/expected_array.json")
    allow(Search).to(receive(:execute_query).and_return(load_file("./stubs/vangogh_artworks_10_2025/van-gogh-paintings.html")))
    result = Search.query("van gogh paintings")
    result[:artworks].each_with_index do |artwork, index|
      expected_hash = expectation["artworks"][index].transform_keys(&:to_sym)
      expect(artwork).to(eq(expected_hash))
    end
  end

  it "extracts movies from 2025 page" do
    expectation = load_json("./stubs/the_rock_movies_2025/expected_array.json")
    allow(Search).to(receive(:execute_query).and_return(load_file("./stubs/the_rock_movies_2025/the_rock_movies.html")))
    result = Search.query("the rock movies")
    result[:movies].each_with_index do |artwork, index|
      expected_hash = expectation["movies"][index].transform_keys(&:to_sym)

      expect(artwork).to(eq(expected_hash))
    end
  end

  it "extracts books from 2025 page" do
    expectation = load_json("./stubs/vangogh_books_2025/expected_array.json")
    allow(Search).to(receive(:execute_query).and_return(load_file("./stubs/vangogh_books_2025/vangogh_books.html")))
    result = Search.query("vangogh books")
    result[:books].each_with_index do |artwork, index|
      expected_hash = expectation["books"][index].transform_keys(&:to_sym)

      expect(artwork).to(eq(expected_hash))
    end
  end
end
