require 'clipboard'
require 'tty-table'
require 'tty-prompt'
require 'logger'

module Snippet
  # Command line interface helpers and actions
  module CLI
    # CLI Actions
    module Commands
      ##
      # Show displays a snippet
      #
      def self.show(
        lang,
        copy,
        vars = []
      )
        name = vars.first
        snippet_dir = Snippet::CLI.snip_dir

        manager = Snippet::Manager.new(snippet_dir)
        manager.load_snippets

        snips = manager.find(name, lang)
        raise "unable to find #{name}" if snips.empty?

        snip = snips.first
        if snips.length > 1
          snip = CLI::Presenters.pick_from(
            'Multiple snippets found, which one would you like to view?',
            snips
          )
        end

        if copy
          Clipboard.copy(snip.content)
          CLI.print_message("COPIED: #{snip.path}")
        end

        CLI::Presenters.show(snip)
      end

      ##
      # List lists snippets
      #
      def self.list(
        lang,
        _copy,
        _vars = []
      )
        snippet_dir = Snippet::CLI.snip_dir

        manager = Snippet::Manager.new(snippet_dir)
        manager.load_snippets

        snippets = lang ? manager.filter_by_extension(lang) : manager.snippets

        CLI::Presenters.list_snippets(snippets)
      end

      ##
      # Show snippet directory path
      #
      def self.path(
        _lang,
        _copy,
        _vars = []
      )
        CLI.print_message("SNIPPET_DIR: #{CLI.snip_dir}")
      end
    end

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

    # CLI Helpers
    class <<self
      ##
      # Retrieves snippet dir from environment
      #
      def snip_dir
        @snippet_dir = ENV['SNIPPET_DIR']
        raise 'SNIPPET_DIR environment variable not set' unless @snippet_dir
        unless File.exist?(@snippet_dir)
          raise "SNIPPET_DIR #{@snippet_dir} does not exist"
        end

        @snippet_dir
      end

      ##
      # Creates logger for printing messages
      #
      def logger
        @logger ||= Logger.new(STDOUT)
        @logger.formatter = proc do |_sev, _time, _prog, msg|
          "#{msg}\n"
        end

        @logger
      end

      ##
      # Prints command line message to CLI
      #
      def print_message(message)
        logger.info(message)
      end

      ##
      # Prints a message and then exits with given status code
      #
      def print_message_and_exit(message, exit_code = 1)
        print_message(message)
        exit(exit_code)
      end
    end
  end
end
