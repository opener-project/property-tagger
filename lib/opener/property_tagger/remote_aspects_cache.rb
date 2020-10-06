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
          if existing = @cache[params]
            existing.tap do
              Thread.new{ @cache[params] = cache_update existing, **params }
            end
          else
            @cache[params] = cache_update **params
          end
        end
      end
      alias_method :get, :[]

      def cache_update existing = nil, **params
        from     = Time.now
        lexicons = load_aspects cache: existing, **params

        return existing if existing and lexicons.blank?
        Hashie::Mash.new(
          aspects: lexicons,
          from:    from,
        )
      end

      def load_aspects lang:, cache:, **params
        url      = "#{@url}&language_code=#{lang}&#{params.to_query}"
        url     += "&if_updated_since=#{cache.from.iso8601}" if cache
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
