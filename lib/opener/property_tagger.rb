require 'open3'
require 'slop'

require_relative 'property_tagger/version'
require_relative 'property_tagger/cli'
require_relative 'property_tagger/processor'

module Opener
  ##
  # Ruby wrapper around the Python based polarity tagger.
  #
  # @!attribute [r] options
  #  @return [Hash]
  #
  # @!attribute [r] args
  #  @return [Array]
  #
  class PropertyTagger
    attr_reader :options, :args

    ##
    # @param [Hash] options
    #
    # @option options [Array] :args Collection of arbitrary arguments to pass
    #  to the underlying kernel.
    #
    def initialize(options = {})
      @args    = options.delete(:args) || []
      @options = options
    end

    ##
    # Get the resource path for the lexicon files, defaults to an ENV variable
    #
    # @return [String]
    #
    def path
      path = options[:resource_path] || ENV['RESOURCE_PATH'] ||
        ENV['PROPERTY_TAGGER_LEXICONS_PATH']

      unless path
        raise ArgumentError, 'No lexicon path provided'
      end

      return path
    end

    ##
    # Processes the input and returns an Array containing the output of STDOUT,
    # STDERR and an object containing process information.
    #
    # @param [String] input The text of which to detect the language.
    # @return [Array]
    #
    def run(input)
      output = process(input)

      return output
    end

    protected

    ##
    # capture3 method doesn't work properly with Jruby, so
    # this is a workaround
    #
    def process(input)
      processor = Opener::PropertyTagger::Processor.new(input, !args.include?("--no-time"))
      return processor.process
    end
  end # PolarityTagger
end # Opener

