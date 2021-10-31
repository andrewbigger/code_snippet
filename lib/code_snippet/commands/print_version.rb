require 'tty-prompt'

module CodeSnippet
  module Commands
    # Prints snippet path to STDOUT
    class PrintVersion
      def initialize(options = Hashie::Mash.new)
        @options = options
        @prompt = TTY::Prompt.new
      end

      ##
      # Prints snippet path
      #
      def run
        puts(CodeSnippet::VERSION)
      end
    end
  end
end
