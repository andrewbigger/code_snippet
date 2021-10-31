require 'tty-prompt'

module CodeSnippet
  module Commands
    # Shows snippet in STDOUT
    class ShowSnippet
      def initialize(manager, options = Hashie::Mash.new)
        @manager = manager
        @options = options
        @prompt = TTY::Prompt.new
      end

      ##
      # Prints snippet path
      #
      def run
        name = @options.name
        name ||= @prompt.select(
          'Please choose snippet',
          @manager.snippet_names
        )

        snips = find_snippets(name)
        snip = pick_snippet(snips)

        if @options.copy
          Clipboard.copy(snip.content)
          puts "COPIED: #{snip.path}"
        end

        puts snip.content
      end

      private

      def find_snippets(name)
        snips = @manager.find(name)
        raise "unable to find #{name}" if snips.empty?
      end

      def pick_snippet(snips)
        snip = snips.first
        if snips.length > 1
          snip_name = @prompt.select(
            'Multiple snippets found, which one would you like to view?',
            snips.map(&:name)
          )

          snip = @manager.find(snip_name).first
        end

        snip
      end
    end
  end
end
