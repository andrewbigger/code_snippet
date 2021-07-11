require 'code_snippet/cli/commands'
require 'code_snippet/cli/presenters'

require 'logger'

module CodeSnippet
  # Command line interface helpers and actions
  module CLI
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
