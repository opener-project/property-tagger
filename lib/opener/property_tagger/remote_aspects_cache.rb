module Opener
  class PropertyTagger
    ##
    # Thread-safe cache for storing the contents of remote aspects.
    #
    class RemoteAspectsCache

      include MonitorMixin

      UPDATE_INTERVAL = (ENV['CACHE_EXPIRE_MINS']&.to_i || 5).minutes

      def initialize
        super

        @url   = ENV['PROPERTY_TAGGER_LEXICONS_URL']
        @cache = {}
      end

      def [] **params
        synchronize do
          existing = @cache[params]
          break existing if existing and existing.from > UPDATE_INTERVAL.ago
          @cache[params] = cache_update existing, **params
        end
      end
      alias_method :get, :[]

      def cache_update existing = nil, **params
        from     = Time.now
        lexicons = load_aspects cache: existing, **params

        if existing and lexicons.blank?
          existing.from = from
          return existing
        end

        Hashie::Mash.new(
          aspects: lexicons,
          from:    from,
        )
      end

      def load_aspects lang:, cache:, **params
        url  = "#{@url}&language_code=#{lang}&#{params.to_query}"
        url += "&if_updated_since=#{cache.from.utc.iso8601}" if cache
        puts "#{lang}: loading aspects from #{url}"

        lexicons = JSON.parse HTTPClient.new.get(url).body
        lexicons = lexicons['data'].map{ |l| Hashie::Mash.new l }
        mapping  = Hash.new{ |hash, key| hash[key] = [] }
        lexicons.each do |l|
          mapping[l.lemma.to_sym] << l.aspect
        end

        mapping
      end

    end
  end
end
