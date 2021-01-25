module Opener
  class PropertyTagger
    ##
    # Thread-safe cache for storing the contents of aspect files.
    #
    class FileAspectsCache

      include MonitorMixin

      def initialize
        super

        @cache = {}
      end

      ##
      # Returns the aspects for the given file path. If the aspects don't exist
      # they are first loaded into the cache.
      #
      # @param [String] path
      #
      def [](path)
        synchronize do
          @cache[path] = load_aspects(path) unless @cache.key?(path)
        end
      end

      alias_method :get, :[]

      ##
      # Loads the aspects of the given path.
      #
      # @param [String] path
      #
      def load_aspects(path)
        mapping = Hash.new{ |hash, key| hash[key] = [] }

        File.foreach path do |line|
          lemma, pos, aspect = line.chomp.split("\t")
          l = Hashie::Mash.new(
            lemma:  lemma,
            pos:    pos,
            aspect: aspect,
          )

          mapping[l.lemma.to_sym] << l
        end

        return mapping
      end

    end
  end
end
