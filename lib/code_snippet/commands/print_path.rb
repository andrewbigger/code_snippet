require 'tty-prompt'

module CodeSnippet
  module Commands
    # Prints gem version to STDOUT
    class PrintPath
      def initialize(snip_dir, options = Hashie::Mash.new)
        @snip_dir = snip_dir
        @options = options
        @prompt = TTY::Prompt.new
      end

      ##
      # Prints gem version
      #
      def run
        puts(@snip_dir)
      end
    end
  end
end
