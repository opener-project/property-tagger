require 'open3'
require 'slop'

require_relative 'property_tagger/version'
require_relative 'property_tagger/cli'

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
    # Returns a String containing the command to use for executing the kernel.
    #
    # @return [String]
    #
    def command
      return "python -E #{kernel} #{args.join(' ')} --path #{path}"
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
      stdout, stderr, process = capture(input)

      raise stderr unless process.success?

      return stdout
    end

    protected

    ##
    # capture3 method doesn't work properly with Jruby, so
    # this is a workaround
    #
    def capture(input)
      Open3.popen3(*command.split(" ")) {|i, o, e, t|
        out_reader = Thread.new { o.read }
        err_reader = Thread.new { e.read }
        i.write input
        i.close
        [out_reader.value, err_reader.value, t.value]
      }
    end

    ##
    # @return [String]
    #
    def core_dir
      return File.expand_path('../../../core', __FILE__)
    end

    ##
    # @return [String]
    #
    def kernel
      return File.join(core_dir, 'hotel_property_tagger_nl_en.py')
    end
  end # PolarityTagger
end # Opener

