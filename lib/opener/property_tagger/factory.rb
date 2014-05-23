module Opener
  class PropertyTagger
    ##
    # Creates a new instance of {Opener::PropertyTagger} with a set of options
    # passed in. Using this class we can create daemon instances with custom
    # options.
    #
    # @!attribute [r] options
    #  @return [Hash]
    #
    class Factory
      attr_reader :options

      ##
      # @param [Hash] options The options to pass to each instance.
      #
      def initialize(options = {})
        @options = options
      end

      ##
      # Returns a new instance of the property tagger.
      #
      # @return [Opener::PropertyTagger]
      #
      def new
        return PropertyTagger.new(options.dup)
      end
    end # Factory
  end # PropertyTagger
end # Opener
