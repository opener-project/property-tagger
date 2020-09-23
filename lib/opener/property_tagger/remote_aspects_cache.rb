module Opener
  class PropertyTagger
    ##
    # Thread-safe cache for storing the contents of remote aspects.
    #
    class RemoteAspectsCache

      include MonitorMixin

      def initialize
        super

        @url   = ENV['PROPERTY_TAGGER_LEXICONS_URL']
        @cache = {}
      end

      def [] lang
        synchronize do
          @cache[lang] ||= load_aspects lang
        end
      end
      alias_method :get, :[]

      def load_aspects lang
        mapping  = Hash.new{ |hash, key| hash[key] = [] }
        url      = "#{@url}&language_code=#{lang}"
        lexicons = JSON.parse HTTPClient.new.get(url).body
        lexicons = lexicons['data'].map{ |l| Hashie::Mash.new l }
        puts "#{lang}: loaded aspects from #{url}"

        lexicons.each do |l|
          mapping[l.lemma.to_sym] << l.aspect
        end

        return mapping
      end

    end
  end
end
