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

      def [] **params
        synchronize do
          existing = @cache[params]
          lexicons = load_aspects cache: existing, **params

          @cache[params] = if lexicons.blank? then existing else
            Hashie::Mash.new(
              aspects: lexicons,
              from:    Time.now,
            )
          end
        end
      end
      alias_method :get, :[]

      def load_aspects lang:, cache:, **params
        mapping  = Hash.new{ |hash, key| hash[key] = [] }
        url      = "#{@url}&language_code=#{lang}&#{params.to_query}"
        url     += "&if_updated_since=#{cache.from.iso8601}" if cache
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
