require 'nokogiri'
require 'rexml/document'
require 'rexml/formatters/pretty'
require 'yaml'

module Opener
  class PropertyTagger
    ##
    # Class that applies property tagging to a given input KAF file.
    #
    class Processor
      attr_accessor :document, :aspects_path, :language, :aspects, :terms, :timestamp

      def initialize(file, aspects_path, timestamp = true)
        @document = Nokogiri::XML(file)
        @aspects_path = aspects_path
        raise 'Error parsing input. Input is required to be KAF' unless is_kaf?
        @timestamp = timestamp
      end


      ##
      # Processes the input and returns the new KAF output.
      # @return [String]
      #
      def process
        @language = get_language
        @aspects  = load_aspects
        @terms    = get_terms

        existing_aspects = extract_aspects

        add_features_layer
        add_properties_layer

        index = 1

        existing_aspects.each_pair do |key,value|
          add_property(key, value, index)
          index += 1
        end

        add_linguistic_processor

        return pretty_print(document)
      end

      ##
      # Loads the aspects from the txt file
      # @return [Hash]
      #
      def load_aspects
        aspects_hash = Hash.new
        File.foreach(aspects_file) do |line|
          lemma, pos, aspect = line.gsub("\n", "").split("\t")
          aspects_hash[lemma.to_sym] = {
            :pos => pos,
            :aspect => aspect
          }
        end

        return aspects_hash
      end

      ##
      # Get the language of the input file.
      # @return [String]
      #
      def get_language
        document.root.attr('xml:lang')
      end

      ##
      # Get the terms from the input file
      # @return [Hash]
      #
      def get_terms
        terms_hash = Hash.new
        document.at('terms').css('term').each do |term|
          terms_hash[term.attr('tid').to_sym] = term.attr('lemma')
        end

        return terms_hash
      end

      ##
      # Check which terms belong to an aspect (property)
      # @return [Hash]
      #
      def extract_aspects
        term_ids  = terms.keys
        lemmas    = terms.values

        current_token = 0
        # Use of n-grams to determine if a unigram (1 lemma) or bigram (2
        # lemmas) belong to a property.
        max_ngram = 2

        uniq_aspects = {}

        while current_token < terms.count
          (0..max_ngram).each do |tam_ngram|
            if current_token + tam_ngram <= terms.count
              ngram  = lemmas[current_token..current_token+tam_ngram].join(" ").downcase
              if aspects[ngram.to_sym] && !aspects[ngram.to_sym][:aspect].gsub(" ", "").empty?
                aspect = aspects[ngram.to_sym][:aspect]
                ids    = term_ids[current_token..current_token+tam_ngram]
                uniq_aspects[aspect.to_sym] = [] unless uniq_aspects[aspect.to_sym]
                uniq_aspects[aspect.to_sym] << [ids,ngram]
              end
            end
          end
          current_token += 1
        end

        return Hash[uniq_aspects.sort]
      end

      ##
      # Remove the features layer from the KAF file if it exists and add a new
      # one.
      def add_features_layer
        document.at('features').remove if document.at('features')
        new_node("features", "KAF")
      end

      ##
      # Add the properties layer as a child to the features layer.
      def add_properties_layer
        new_node("properties", "features")
      end

      def add_property(key, value, index)
        property_node = new_node("property", "properties")
        property_node['lemma'] = key.to_s
        property_node['pid']   = "p#{index.to_s}"
        references_node = new_node("references", property_node)
        value.uniq.each do |v|
          comment = Nokogiri::XML::Comment.new(references_node, v.last)
          references_node.add_child(comment)
          span_node = new_node("span", references_node)
          v.first.each do |val|
            target_node = new_node("target", span_node)
            target_node['id'] = val.to_s
          end
        end
      end

      def add_linguistic_processor
        description = 'VUA property tagger'
        last_edited = '16jan2015'
        version     = '2.0'

        node = new_node("linguisticProcessors", "kafHeader")
        node['layer'] = "features"
        lp_node = new_node("lp", node)
        lp_node['version'] = [last_edited, version].join("_")
        lp_node['name']    = description

        if timestamp
          format = "%Y-%m-%dT%H:%M:%S%Z"
          lp_node['timestamp'] = Time.now.strftime(format)
        else
          lp_node['timestamp'] = "*"
        end
      end

      ##
      # Format the output document properly.
      # Nokogiri isn't very good at that so we abuse REXML for that.
      # @return [String]
      #
      def pretty_print(document)
        doc = REXML::Document.new document.to_xml
        doc.context[:attribute_quote] = :quote
        out = ""
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        formatter.write(doc, out)

        return out
      end

      protected
      def new_node(tag, parent)
        parent_node =  parent.kind_of?(String) ? document.at(parent) : parent
        node = Nokogiri::XML::Node.new tag, parent_node
        parent_node.add_child(node)

        return node
      end

      ##
      # Check if input is a KAF file.
      # @return [Boolean]
      #
      def is_kaf?
        !!document.at("KAF")
      end

      def aspects_file
        File.expand_path("#{aspects_path}/#{language}.txt", __FILE__)
      end
    end # Processor
  end # PropertyTagger
end # Opener
