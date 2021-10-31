require 'thor'
require 'logger'

require 'code_snippet'
require 'code_snippet/commands'

module CodeSnippet
  # Command line interface helpers and actions
  class CLI < ::Thor
    package_name 'CodeSnippet'

    desc 'version', 'Print code snippet version to STDOUT'

    ##
    # Runs version command
    #
    def version
      cmd = CodeSnippet::Commands::PrintVersion.new(options)
      cmd.run
    end

    map %w[--version -v] => :version

    desc 'path', 'Print snippet directory path to STDOUT'

    ##
    # Runs version command
    #
    def path
      cmd = CodeSnippet::Commands::PrintPath.new(snip_dir, options)
      cmd.run
    end

    desc 'show', 'Find and show snippet'

    method_option(
      :name,
      type: :string,
      desc: 'Name of snippet'
    )

    method_option(
      :copy,
      type: :boolean,
      desc: 'Should copy snippet to clipboard',
      default: false
    )

    ##
    # Show snippet command
    #
    def show
      cmd = CodeSnippet::Commands::ShowSnippet.new(manager, options)
      cmd.run
    end

    desc 'list', 'List all known snippets'

    ##
    # Show snippet command
    #
    def list
      cmd = CodeSnippet::Commands::ListSnippets.new(manager, options)
      cmd.run
    end


    protected

    ##
    # Retrieves snippet dir from environment
    #
    def snip_dir
      @snippet_dir = ENV['SNIPPET_DIR']

      unless @snippet_dir
        raise 'SNIPPET_DIR environment variable not set' 
      end

      unless File.exist?(@snippet_dir)
        raise "SNIPPET_DIR #{@snippet_dir} does not exist"
      end

      @snippet_dir
    end

    ##
    # Loads and creates snippet manager
    #
    # @return [CodeSnippet::Manager]
    #
    def manager
      @manager ||= CodeSnippet::Manager.new(snip_dir)
      @manager.load

      @manager
    end

    # CLI Helpers
    class <<self
      

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
