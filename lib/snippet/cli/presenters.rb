require 'tty-table'
require 'tty-prompt'

module Snippet
  # Command line interface helpers and actions
  module CLI
    # CLI Presentation functions
    module Presenters
      def self.pick_from(question, snips)
        prompt = TTY::Prompt.new

        choice = prompt.select(
          question,
          snips.map(&:path)
        )

        snips.find { |snip| snip.path == choice }
      end

      def self.show(snip)
        puts snip.content
      end

      def self.list_snippets(snippets)
        result_header = %w[NAME LANG PATH]

        results = TTY::Table.new(
          result_header,
          snippets.map do |snippet|
            [
              snippet.name,
              snippet.ext,
              snippet.path
            ]
          end
        )

        puts results.render(:ascii)
      end
    end
  end
end
