module Opener
  class PropertyTagger
    ##
    # Class that applies property tagging to a given input KAF file.
    #
    class Processor

      attr_accessor :document
      attr_accessor :aspects_path, :aspects_url
      attr_accessor :aspects, :lexicons
      attr_accessor :timestamp, :pretty

      ##
      # Global cache used for storing loaded aspects.
      #
      # @return [Opener::PropertyTagger::FileAspectsCache.new]
      #
      FILE_ASPECTS_CACHE   = FileAspectsCache.new
      REMOTE_ASPECTS_CACHE = RemoteAspectsCache.new

      ##
      # @param [String|IO] file The KAF file/input to process.
      # @param [String] aspects_path Path to the aspects.
      # @param [TrueClass|FalseClass] timestamp Add timestamps to the KAF.
      # @param [TrueClass|FalseClass] pretty Enable pretty formatting, disabled
      #  by default due to the performance overhead.
      #
      def initialize file, params: {}, url: nil, path: nil, timestamp: true, pretty: false
        @document     = Nokogiri.XML file
        raise 'Error parsing input. Input is required to be KAF' unless is_kaf?
        @timestamp    = timestamp
        @pretty       = pretty

        @params       = params
        @remote       = !url.nil?
        @aspects_path = path
        @aspects_url  = url
        @cache_keys   = params[:cache_keys] || {}
        @cache_keys.merge! lang: @document.root.attr('xml:lang')

        @lexicons = if @remote then REMOTE_ASPECTS_CACHE[**@cache_keys].aspects else FILE_ASPECTS_CACHE[aspects_file] end
      end

      ##
      # Processes the input and returns the new KAF output.
      # @return [String]
      #
      def process
        add_features_layer
        add_properties_layer

        extract_aspects.each.with_index do |(lemma, values), index|
          index += 1

          add_property lemma, values, index
        end

        add_linguistic_processor

        pretty ? pretty_print(document) : document.to_xml
      end

      def language
        @language ||= document.at_xpath('KAF').attr('xml:lang')
      end

      def terms
        unless @terms
          @terms = {}

          document.xpath('KAF/terms/term').each do |term|
            @terms[term.attr('tid').to_sym] = { lemma: term.attr('lemma'), text: term.attr('text')}
          end
        end

        @terms
      end

      # Use of n-grams to determine if a unigram (1 lemma) or bigram (2
      # lemmas) belong to a property.
      MAX_NGRAM = 2

      ##
      # Check which terms belong to an aspect (property)
      # Text have priority over Lemmas, overriding if there is a conflict
      # @return [Hash]
      #
      def extract_aspects
        all_term_ids = terms.keys
        lemmas       = terms.values
        uniq_aspects = Hash.new{ |hash, lemma| hash[lemma] = [] }

        [:lemma, :text].each do |k|
          current_token = 0

          while current_token < terms.count
            (0..MAX_NGRAM).each do |tam_ngram|
              next unless current_token + tam_ngram <= terms.count

              ngram = lemmas[current_token..current_token+tam_ngram].map{ |a| a[k] }.join(" ").downcase

              @lexicons[ngram.to_sym]&.each do |l|
                properties = if l.aspects.present? then l.aspects else [l.aspect] end
                properties.each do |p|
                  next if p.blank?
                  term_ids = all_term_ids[current_token..current_token+tam_ngram]
                  next if uniq_aspects[p.to_sym].find{ |v| v.term_ids == term_ids }

                  uniq_aspects[p.to_sym] << Hashie::Mash.new(
                    term_ids: term_ids,
                    ngram:    ngram,
                    lexicon:  l,
                  )
                end
              end
            end
            current_token += 1
          end
        end

        Hash[uniq_aspects.sort]
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

      def add_property lemma, values, index
        property_node = new_node("property", "KAF/features/properties")

        property_node['lemma'] = lemma.to_s
        property_node['pid']   = "p#{index.to_s}"

        references_node = new_node("references", property_node)

        values.each do |v|
          comm_node = Nokogiri::XML::Comment.new(references_node, " #{v.ngram} ")
          references_node.add_child comm_node

          span_node = new_node 'span', references_node

          v.term_ids.each do |id|
            target_node       = new_node 'target', span_node

            target_node['id'] = id.to_s
            target_node['lexicon-id'] = v.lexicon.id if v.lexicon.id
          end
        end
      end

      def add_linguistic_processor
        description = 'VUA property tagger'
        last_edited = '16jan2015'
        version     = '2.0'

        node = new_node('linguisticProcessors', 'KAF/kafHeader')
        node['layer'] = 'features'

        lp_node = new_node('lp', node)

        lp_node['version'] = "#{last_edited}-#{version}"
        lp_node['name']    = description

        if timestamp
          format = '%Y-%m-%dT%H:%M:%S%Z'

          lp_node['timestamp'] = Time.now.strftime(format)
        else
          lp_node['timestamp'] = '*'
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

        out.strip
      end

      protected

      def new_node(tag, parent)
        if parent.is_a?(String)
          parent_node = document.at_xpath(parent)
        else
          parent_node = parent
        end

        node = Nokogiri::XML::Element.new(tag, document)

        parent_node.add_child node

        node
      end

      ##
      # Check if input is a KAF file.
      # @return [Boolean]
      #
      def is_kaf?
        !!document.at_xpath('KAF')
      end

      ##
      # @return [String]
      #
      def aspects_file
        @aspects_file ||= File.expand_path "#{aspects_path}/#{language}.txt", __FILE__
      end

    end
  end
end
