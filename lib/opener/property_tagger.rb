require 'open3'
require 'slop'
require 'oga'
require 'monitor'

require 'rexml/document'
require 'rexml/formatters/pretty'

require_relative 'property_tagger/version'
require_relative 'property_tagger/cli'
require_relative 'property_tagger/aspects_cache'
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
    # @option options [TrueClass] :no_time Disables adding of timestamps.
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

      return File.expand_path(path)
    end

    ##
    # Processes the input KAF document.
    #
    # @param [String] input
    # @return [String]
    #
    def run(input)
      timestamp = !options[:no_time]

      return Processor.new(input, path, timestamp, options[:pretty]).process
    end
  end # PolarityTagger
end # Opener

