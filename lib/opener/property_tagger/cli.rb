require 'opener/core'

module Opener
  class PropertyTagger
    ##
    # CLI wrapper around {Opener::PropertyTagger} using OptionParser.
    #
    # @!attribute [r] parser
    #  @return [Slop]
    #
    class CLI
      attr_reader :parser

      def initialize
        @parser = configure_slop
      end

      ##
      # @param [Array] argv
      #
      def run(argv = ARGV)
        parser.parse(argv)
      end

      ##
      # @return [Slop]
      #
      def configure_slop
        return Slop.new(:strict => false, :indent => 2, :help => true) do
          banner 'Usage: property-tagger [OPTIONS] -- [PYTHON OPTIONS]'

          separator <<-EOF.chomp

About:

    Component for finding the properties in a KAF document. This command reads
    input from STDIN.

Examples:

    Processing a KAF file:

        cat some_file.kaf | property-tagger

    Displaying the underlying kernel options:

        property-tagger -- --help

          EOF

          separator "\nOptions:\n"

          on :v, :version, 'Shows the current version' do
            abort "property-tagger v#{VERSION} on #{RUBY_DESCRIPTION}"
          end

          on :'no-time', 'Disables adding of timestamps'

          on :ugly, 'Disables pretty formatting of XML (faster)'

          run do |opts, args|
            tagger = PropertyTagger.new(
              :args    => args,
              :no_time => opts[:'no-time'],
              :pretty  => !opts[:ugly]
            )

            input  = STDIN.tty? ? nil : STDIN.read

            puts tagger.run(input)
          end
        end
      end
    end # CLI
  end # PropertyTagger
end # Opener
