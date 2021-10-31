require 'clipboard'

module CodeSnippet
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
        args = []
      )
        name = args.first
        snippet_dir = CodeSnippet::CLI.snip_dir

        manager = CodeSnippet::Manager.new(snippet_dir)
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
        _args = []
      )
        snippet_dir = CodeSnippet::CLI.snip_dir

        manager = CodeSnippet::Manager.new(snippet_dir)
        manager.load_snippets

        snippets = lang ? manager.filter_by_extension(lang) : manager.snippets

        CLI::Presenters.list_snippets(snippets)
      end

    end
  end
end
