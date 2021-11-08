require 'tty-prompt'
require 'tty-table'

module CodeSnippet
  module Commands
    # Lists snippets in STDOUT
    class ListSnippets
      ##
      # Output table header
      #
      RESULT_HEADER = %w[NAME LANG].freeze

      def initialize(manager, options = Hashie::Mash.new)
        @manager = manager
        @options = options
        @prompt = TTY::Prompt.new
      end

      ##
      # Prints a list of snippets to STDOUT
      #
      def run
        puts(snippet_list_table.render.strip)
      end

      private

      def snippet_list_table
        TTY::Table.new(
          header: RESULT_HEADER,
          rows: @manager.snippets.map do |snip|
            [
              snip.name.downcase,
              snip.ext
            ]
          end
        )
      end
    end
  end
end
