module Opener
  class PropertyTagger
    ##
    # Class that applies property tagging to a given input KAF file.
    #
    class Processor
      attr_accessor :document, :aspects_path, :timestamp, :pretty

      ##
      # Global cache used for storing loaded aspects.
      #
      # @return [Opener::PropertyTagger::AspectsCache.new]
      #
      ASPECTS_CACHE = AspectsCache.new

      ##
      # @param [String|IO] file The KAF file/input to process.
      # @param [String] aspects_path Path to the aspects.
      # @param [TrueClass|FalseClass] timestamp Add timestamps to the KAF.
      # @param [TrueClass|FalseClass] pretty Enable pretty formatting, disabled
      #  by default due to the performance overhead.
      #
      def initialize(file, aspects_path, timestamp = true, pretty = false)
        @document     = Oga.parse_xml(file)
        @aspects_path = aspects_path
        @timestamp    = timestamp
        @pretty       = pretty

        raise 'Error parsing input. Input is required to be KAF' unless is_kaf?
      end

      ##
      # Processes the input and returns the new KAF output.
      # @return [String]
      #
      def process
        existing_aspects = extract_aspects

        add_features_layer
        add_properties_layer

        existing_aspects.each_with_index do |(key, value), index|
          index += 1

          add_property(key, value, index)
        end

        add_linguistic_processor

        return pretty ? pretty_print(document) : document.to_xml
      end

      ##
      # @return [Hash]
      #
      def aspects
        return ASPECTS_CACHE[aspects_file]
      end

      ##
      # Get the language of the input file.
      #
      # @return [String]
      #
      def language
        return @language ||= document.at_xpath('KAF').get('xml:lang')
      end

      ##
      # Get the terms from the input file
      # @return [Hash]
      #
      def terms
        unless @terms
          @terms = {}

          document.xpath('KAF/terms/term').each do |term|
            @terms[term.get('tid').to_sym] = term.get('lemma')
          end
        end

        return @terms
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

        uniq_aspects = Hash.new { |hash, key| hash[key] = [] }

        while current_token < terms.count
          (0..max_ngram).each do |tam_ngram|
            if current_token + tam_ngram <= terms.count
              ngram = lemmas[current_token..current_token+tam_ngram].join(" ").downcase

              if aspects[ngram.to_sym]
                properties = aspects[ngram.to_sym]
                ids        = term_ids[current_token..current_token+tam_ngram]

                properties.uniq.each do |property|
                  next if !property or property.strip.empty?

                  uniq_aspects[property.to_sym] << [ids,ngram]
                end
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
        existing = document.at_xpath('KAF/features')

        existing.remove if existing

        new_node('features', 'KAF')
      end

      ##
      # Add the properties layer as a child to the features layer.
      def add_properties_layer
        new_node("properties", "KAF/features")
      end

      def add_property(key, value, index)
        property_node = new_node("property", "KAF/features/properties")

        property_node.set('lemma', key.to_s)
        property_node.set('pid', "p#{index.to_s}")

        references_node = new_node("references", property_node)

        value.uniq.each do |v|
          comment = Oga::XML::Comment.new(:text => " #{v.last} ")

          references_node.children << comment

          span_node = new_node("span", references_node)

          v.first.each do |val|
            target_node = new_node("target", span_node)

            target_node.set('id', val.to_s)
          end
        end
      end

      def add_linguistic_processor
        description = 'VUA property tagger'
        last_edited = '16jan2015'
        version     = '2.0'

        node = new_node('linguisticProcessors', 'KAF/kafHeader')
        node.set('layer', 'features')

        lp_node = new_node('lp', node)

        lp_node.set('version', "#{last_edited}-#{version}")
        lp_node.set('name', description)

        if timestamp
          format = '%Y-%m-%dT%H:%M:%S%Z'

          lp_node.set('timestamp', Time.now.strftime(format))
        else
          lp_node.set('timestamp', '*')
        end
      end

      ##
      # Format the output document properly.
      #
      # TODO: this should be handled by Oga in a nice way.
      #
      # @return [String]
      #
      def pretty_print(document)
        doc = REXML::Document.new document.to_xml
        doc.context[:attribute_quote] = :quote
        out = ""
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        formatter.write(doc, out)

        return out.strip
      end

      protected

      def new_node(tag, parent)
        if parent.is_a?(String)
          parent_node = document.at_xpath(parent)
        else
          parent_node = parent
        end

        node = Oga::XML::Element.new(:name => tag)

        parent_node.children << node

        return node
      end

      ##
      # Check if input is a KAF file.
      # @return [Boolean]
      #
      def is_kaf?
        return !!document.at_xpath('KAF')
      end

      ##
      # @return [String]
      #
      def aspects_file
        return @aspects_file ||=
          File.expand_path("#{aspects_path}/#{language}.txt", __FILE__)
      end
    end # Processor
  end # PropertyTagger
end # Opener
