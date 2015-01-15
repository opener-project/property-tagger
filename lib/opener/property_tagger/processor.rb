require 'nokogiri'
require 'yaml'

module Opener
  class PropertyTagger
    ##
    # Class that applies property tagging to a given input KAF file.
    #
    class Processor
      attr_accessor :document, :language, :aspects, :terms, :timestamp
      
      def initialize(file, timestamp = true)
        @document = Nokogiri::XML(file)
        raise 'Error parsing input. Input is required to be KAF' unless is_kaf?
        @timestamp = timestamp
      end
      
      def process
        @language = get_language
        @aspects  = load_aspects
        @terms    = get_terms        
        
        existing_aspects = extract_aspects
        
        add_features_layer
        add_properties_layer
        
        index = 1
        
        existing_aspects.each_pair do |key,value|
          value.uniq.each do |v|
            add_property(key, v, index)
          end
          index += 1
        end
        
        add_linguistic_processor
        
        return document.to_xml(:indent => 2)
      end
      
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

      def get_language
        document.root.attr('xml:lang')
      end
      
      def get_terms
        terms_hash = Hash.new
        document.at('terms').css('term').each do |term|
          terms_hash[term.attr('tid').to_sym] = term.attr('lemma')
        end
        
        return terms_hash
      end
      
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
              if aspects[ngram.to_sym]
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
      
      def add_features_layer
        document.at('features').remove if document.at('features')
        node = Nokogiri::XML::Node.new "features", document
        document.root.add_child(node)
      end
      
      def add_properties_layer
        features_node = document.at('features')
        node = Nokogiri::XML::Node.new "properties", features_node
        features_node.add_child(node)
      end
      
      def add_property(key, value, index)
        properties_node = document.at('properties')
        property_node = Nokogiri::XML::Node.new "property", properties_node
        properties_node.add_child(property_node)
        property_node['pid']   = "p#{index.to_s}"
        property_node['lemma'] = key.to_s
        references_node = Nokogiri::XML::Node.new "references", property_node
        property_node.add_child(references_node)
        references_node.inner_html = "<!--#{value.last}-->\n"
        span_node = Nokogiri::XML::Node.new "span", references_node
        references_node.add_child(span_node)
        value.first.each do |v|
          target_node = Nokogiri::XML::Node.new "target", span_node
          span_node.add_child(target_node)
          target_node['id'] = v.to_s
        end
      end
      
      def add_linguistic_processor
        description = 'VUA property tagger'
        last_edited = '20may2014'
        version     = '1.0'
        
        kaf_header_node = document.at('kafHeader')
        node = Nokogiri::XML::Node.new "linguisticProcessors", kaf_header_node
        kaf_header_node.add_child(node)
        node['layer'] = "features"
        lp_node = Nokogiri::XML::Node.new "lp", node
        node.add_child(lp_node)
        lp_node['version'] = [last_edited, version].join("_")
        lp_node['name']    = description
        
        if timestamp
          format = "%Y-%m-%dT%H:%M:%S%Z"
          lp_node['timestamp'] = Time.now.strftime(format)
        end
      end
      
      protected
      ##
      # Check if input is a KAF file.      
      def is_kaf?
        !!document.at("KAF")
      end
      
      def aspects_file
        File.expand_path("../../../../config/#{language}.txt", __FILE__)
      end
    end # Processor
  end # PropertyTagger
end # Opener
