# frozen_string_literal: true

require "nokogiri"

class GoogleParser
  attr_reader :html

  def initialize(html)
    @html = html
  end

  # output hash is in symbols as that is better for memory
  def knowledge_card
    parsed_knowledge_card = {}
    knowledge_card_entries.each do |entry|
      method_name = "kc_#{entry["data-attrid"].split("/").last.gsub(":", "_").split(" ")[0]}"
      parsed_entry = send(method_name, entry)
      parsed_knowledge_card[parsed_entry[0].to_sym] = parsed_entry[1] if parsed_entry
    rescue NoMethodError => error
      # if its not a kc method then raise error so developer sees issue
      raise error unless error.message.include?("kc_")

      # this would be a log to make sure that we implement new kc methods as the google adds more things
      puts "KC Method #{method_name} not defined"
    end
    parsed_knowledge_card
  end

  def kc_author_books(knowledge_card_entry)
    return if knowledge_card_entry["role"]

    result = kc_person_movies(knowledge_card_entry)
    result[0] = "books"
    result
  end

  def kc_person_movies(knowledge_card_entry)
    # movies/books return one kc entry per element
    return if knowledge_card_entry["role"]

    @person_movies ||= begin
      artworks_links = knowledge_card_entry.css("a")
      parsed_artworks = artworks_links.map do |artwork|
        image = artwork.css("img").first
        # how we extract the name has changed
        details = artwork.css("wp-grid-tile div div")
        name = details.first.text
        # everything else stays the same
        date = [artwork.text.gsub(name, "")][0]
        result = {
          link: "https://www.google.com" + artwork["href"],
          name:,
          image: images[image["id"]] || image["data-src"],
        }
        if date != ""
          result[:extensions] = [date]
        end
        result
      end
      ["movies", parsed_artworks]
    end
  end

  def kc_visual_artist_works(knowledge_card_entry)
    @visual_artist_works ||= begin
      artworks_links = knowledge_card_entry.css("a")
      parsed_artworks = artworks_links.map do |artwork|
        image = artwork.css("img").first
        name = image["alt"]
        date = [artwork.text.gsub(name, "")][0]
        result = {
          link: "https://www.google.com" + artwork["href"],
          name:,
          image: images[image["id"]] || image["data-src"],
        }
        if date != ""
          result[:extensions] = [date]
        end
        result
      end
      ["artworks", parsed_artworks]
    end
  end

  def knowledge_card_entries
    @knowledge_card_entries ||= document.css('[data-attrid^="kc:"]')
  end

  def images
    @images ||= begin
      # Regexes that tolerate whitespace, newlines, and single/double quotes
      source_regex   = %r{(data:image\/\S+;base64,\S+);}
      image_id_regex = /var\s+ii\s*=\s*\[([\s\S]*?)\]\s*;/m
      results = []
      document.css("script").each do |script|
        code = script.text
        matched_ii_var = code.match(image_id_regex)
        # dont try match if no ii variable found
        next unless matched_ii_var

        matched_source_var = code.match(source_regex)

        # clean up matched infomation
        id = matched_ii_var[1][1..matched_ii_var[1].length - 2]
        image_source = matched_source_var[0][0..matched_source_var[0].length - 3].gsub("\\x3d", "=")

        # append to  results array
        results << id
        results << image_source
      end
      Hash[*results]
    end
  end

  def document
    @document ||= Nokogiri::HTML(html)
  end
end
