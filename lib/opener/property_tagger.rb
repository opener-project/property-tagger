require 'open3'
require 'slop'
require 'oga'
require 'monitor'
require 'httpclient'
require 'hashie'
require 'json'

require 'rexml/document'
require 'rexml/formatters/pretty'

require_relative 'property_tagger/version'
require_relative 'property_tagger/cli'
require_relative 'property_tagger/aspects_cache'
require_relative 'property_tagger/remote_aspects_cache'
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
      return @path if @path

      @path = options[:resource_path] || ENV['RESOURCE_PATH'] ||
        ENV['PROPERTY_TAGGER_LEXICONS_PATH']
      return unless @path

      @path = File.expand_path @path
    end

    def remote_url
      @remote_url ||= ENV['PROPERTY_TAGGER_LEXICONS_URL']
    end

    ##
    # Processes the input KAF document.
    #
    # @param [String] input
    # @return [String]
    #
    def run input
      timestamp = !options[:no_time]

      Processor.new(input,
        url:       remote_url,
        path:      path,
        timestamp: timestamp,
        pretty:    options[:pretty],
      ).process
    end

  end
end

